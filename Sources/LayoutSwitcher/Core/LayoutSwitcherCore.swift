import CoreGraphics
import AppKit
import os

class LayoutSwitcherCore {
    static let shared = LayoutSwitcherCore()

    /// Set to true while posting synthetic events so EventMonitor ignores them.
    /// Accessed from both main thread and CGEventTap thread — protected by a lock.
    private static let synthesizingLock = OSAllocatedUnfairLock(initialState: false)
    static var isSynthesizing: Bool {
        get { synthesizingLock.withLockUnchecked { $0 } }
        set { synthesizingLock.withLockUnchecked { $0 = newValue } }
    }

    private let source = CGEventSource(stateID: .hidSystemState)

    func replaceWord(_ word: String, with replacement: String, extraBackspaces: Int = 0) {
        LayoutSwitcherCore.isSynthesizing = true
        defer { LayoutSwitcherCore.isSynthesizing = false }
        for _ in 0..<(word.count + extraBackspaces) {
            postKey(51, flags: []) // Backspace
        }
        typeString(replacement)
    }

    func typeString(_ text: String) {
        for scalar in text.unicodeScalars {
            var uniChar = UniChar(scalar.value & 0xFFFF)
            let down = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
            let up = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
            down?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &uniChar)
            up?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &uniChar)
            down?.post(tap: .cgAnnotatedSessionEventTap)
            up?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }

    private func postKey(_ keyCode: CGKeyCode, flags: CGEventFlags) {
        let down = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let up = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        down?.flags = flags
        up?.flags = flags
        down?.post(tap: .cgAnnotatedSessionEventTap)
        up?.post(tap: .cgAnnotatedSessionEventTap)
    }

    /// Select the word to the left of cursor (Option+Shift+Left).
    func selectPreviousWord() {
        postKey(123, flags: [.maskAlternate, .maskShift]) // ⌥⇧←
    }

    // Transform selected text: Cmd+C → transform → Cmd+V
    func transformSelectedText(transform: (String) -> String) {
        let pasteboard = NSPasteboard.general
        let savedContents = pasteboard.string(forType: .string)

        pasteboard.clearContents()
        postKey(8, flags: .maskCommand) // Cmd+C

        Thread.sleep(forTimeInterval: 0.15)

        if let text = pasteboard.string(forType: .string) {
            let transformed = transform(text)
            pasteboard.clearContents()
            pasteboard.setString(transformed, forType: .string)
            postKey(9, flags: .maskCommand) // Cmd+V
        } else if let saved = savedContents {
            pasteboard.clearContents()
            pasteboard.setString(saved, forType: .string)
        }
    }
}
