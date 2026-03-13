import AppKit
import CoreGraphics

class EventMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var tapRunLoop: CFRunLoop?
    private var tapThread: Thread?
    private var currentWordBuffer = ""
    private var lastCompletedWord = ""
    private var lastTriggerKeyCode: Int64 = 49 // Space

    /// Published so MenuBar can show active/inactive indicator
    private(set) var isActive = false

    var onWord: ((String, Int64) -> Void)?
    var onAutoReplace: ((String) -> Void)?

    /// Returns the word to convert manually:
    /// - current buffer if the user is still typing
    /// - last completed word (before space/punct) if buffer is empty
    var wordToConvert: String { currentWordBuffer.isEmpty ? lastCompletedWord : currentWordBuffer }
    var wordToConvertTrigger: Int64 { currentWordBuffer.isEmpty ? lastTriggerKeyCode : -1 }

    func start() {
        tapThread = Thread { [weak self] in
            guard let self else { return }
            let eventMask: CGEventMask =
                (1 << CGEventType.keyDown.rawValue) |
                (1 << CGEventType.keyUp.rawValue) |
                (1 << CGEventType.tapDisabledByTimeout.rawValue) |
                (1 << CGEventType.tapDisabledByUserInput.rawValue)
            guard CGPreflightListenEventAccess() else {
                print("[LinguaSwitch] Input Monitoring not granted")
                DispatchQueue.main.async {
                    self.isActive = false
                    NotificationCenter.default.post(name: .eventTapStatusChanged, object: false)
                }
                return
            }
            let selfPtr = Unmanaged.passUnretained(self).toOpaque()
            guard let tap = CGEvent.tapCreate(
                tap: .cgSessionEventTap,
                place: .headInsertEventTap,
                options: .defaultTap,
                eventsOfInterest: eventMask,
                callback: eventTapCallback,
                userInfo: selfPtr
            ) else {
                print("[LinguaSwitch] Failed to create CGEventTap — accessibility permission required")
                DispatchQueue.main.async {
                    self.isActive = false
                    NotificationCenter.default.post(name: .eventTapStatusChanged, object: false)
                }
                return
            }
            self.eventTap = tap
            self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
            self.tapRunLoop = CFRunLoopGetCurrent()
            CFRunLoopAddSource(self.tapRunLoop, self.runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            DispatchQueue.main.async {
                self.isActive = true
                NotificationCenter.default.post(name: .eventTapStatusChanged, object: true)
            }
            CFRunLoopRun()
        }
        tapThread?.start()
    }

    func stop() {
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let rl = tapRunLoop { CFRunLoopStop(rl) }
        isActive = false
    }

    /// Called from the callback when tap was disabled by macOS — re-enable it immediately.
    func handleTapDisabled() {
        guard let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func processKeyDown(event: CGEvent) -> Unmanaged<CGEvent>? {
        // Ignore synthetic events posted by replaceWord/typeString
        if LayoutSwitcherCore.isSynthesizing { return Unmanaged.passUnretained(event) }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        // Check registered hotkeys first — consume the event if matched
        let relevantFlags = flags.intersection([.maskCommand, .maskShift, .maskAlternate, .maskControl])
        if HotKeyCenter.shared.handle(keyCode: keyCode, modifiers: relevantFlags) {
            return nil // consumed
        }

        // Skip command/control/option modified events
        if flags.contains(.maskCommand) || flags.contains(.maskControl) || flags.contains(.maskAlternate) {
            return Unmanaged.passUnretained(event)
        }

        // Check excluded apps
        if let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier {
            if AppSettings.shared.excludedApps.contains(where: { $0.bundleID == bundleID }) {
                return Unmanaged.passUnretained(event)
            }
        }

        switch keyCode {
        case 51: // Backspace/Delete
            if !currentWordBuffer.isEmpty { currentWordBuffer.removeLast() }

        case 49, 36, 48, 47, 43, 41, 39: // Space, Return, Tab, . , ; '
            if !currentWordBuffer.isEmpty {
                let word = currentWordBuffer
                lastCompletedWord = word
                lastTriggerKeyCode = keyCode
                currentWordBuffer = ""
                let triggerKey = keyCode
                DispatchQueue.main.async { [weak self] in
                    self?.onWord?(word, triggerKey)
                    AutoReplaceManager.shared.checkAndReplace(word: word, triggerKeyCode: triggerKey)
                }
            }

        default:
            // Extract character
            var length = 0
            var chars = [UniChar](repeating: 0, count: 4)
            event.keyboardGetUnicodeString(maxStringLength: 4, actualStringLength: &length, unicodeString: &chars)
            if length > 0, let scalar = Unicode.Scalar(chars[0]) {
                let props = scalar.properties
                if props.isAlphabetic {
                    currentWordBuffer += String(scalar)
                }
            }
        }

        // Diary logging (skip password fields)
        if AppSettings.shared.diaryEnabled {
            logToDiary(event: event, keyCode: keyCode)
        }

        return Unmanaged.passUnretained(event)
    }

    private func logToDiary(event: CGEvent, keyCode: Int64) {
        var length = 0
        var chars = [UniChar](repeating: 0, count: 4)
        event.keyboardGetUnicodeString(maxStringLength: 4, actualStringLength: &length, unicodeString: &chars)
        if length > 0, let scalar = Unicode.Scalar(chars[0]), scalar.properties.isAlphabetic || keyCode == 49 {
            let text = keyCode == 49 ? " " : String(scalar)
            let appName = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
            let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
            if !AppSettings.shared.diaryExcludedApps.contains(bundleID) {
                DiaryManager.shared.record(text: text, appName: appName, bundleID: bundleID)
            }
        }
    }
}

extension Notification.Name {
    static let eventTapStatusChanged = Notification.Name("eventTapStatusChanged")
}

private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let monitor = Unmanaged<EventMonitor>.fromOpaque(refcon).takeUnretainedValue()

    // macOS can disable the tap if the callback is too slow — re-enable immediately
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        monitor.handleTapDisabled()
        return nil
    }

    if type == .keyDown {
        return monitor.processKeyDown(event: event)
    }
    return Unmanaged.passUnretained(event)
}
