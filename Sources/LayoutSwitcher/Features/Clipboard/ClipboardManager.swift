import AppKit
import Combine

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    @Published var history: [String] = []
    private var lastChangeCount: Int = 0
    private var timer: Timer?

    func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopMonitoring() { timer?.invalidate(); timer = nil }

    private func checkClipboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount
        guard let text = pb.string(forType: .string), !text.isEmpty else { return }
        history.removeAll { $0 == text }
        history.insert(text, at: 0)
        if history.count > 30 { history = Array(history.prefix(30)) }
        if AppSettings.shared.diaryTrackClipboard {
            DiaryManager.shared.record(text: "[Clipboard] \(text)", appName: "Clipboard", bundleID: "")
        }
    }

    func switchLayout() {
        guard let text = NSPasteboard.general.string(forType: .string) else { return }
        let lang = LayoutDetector.shared.detectLanguage(of: text) ?? .english
        let target: Language = lang == .english ? AppSettings.shared.primaryLayouts.first(where: { $0 != .english }) ?? .ukrainian : .english
        let converted = TextConverter.shared.convert(text, from: lang, to: target)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(converted, forType: .string)
    }

    func transliterate() {
        guard let text = NSPasteboard.general.string(forType: .string) else { return }
        let result = TextConverter.shared.transliterate(text)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(result, forType: .string)
    }

    func spellCheck() -> String {
        guard let text = NSPasteboard.general.string(forType: .string) else { return "No text in clipboard" }
        let checker = NSSpellChecker.shared
        checker.setLanguage("uk")
        var misspelled: [String] = []
        var range = NSRange(location: 0, length: text.utf16.count)
        while range.location < text.utf16.count {
            let found = checker.checkSpelling(of: text, startingAt: range.location, language: "uk", wrap: false, inSpellDocumentWithTag: 0, wordCount: nil)
            if found.location == NSNotFound { break }
            let word = (text as NSString).substring(with: found)
            misspelled.append(word)
            range.location = found.location + found.length
        }
        return misspelled.isEmpty ? "No misspellings found" : "Misspelled: \(misspelled.joined(separator: ", "))"
    }

    func pasteWithoutFormatting() {
        guard let text = NSPasteboard.general.string(forType: .string) else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        let src = CGEventSource(stateID: .hidSystemState)
        let vDown = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: true)
        vDown?.flags = .maskCommand
        let vUp = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: false)
        vUp?.flags = .maskCommand
        vDown?.post(tap: .cgAnnotatedSessionEventTap)
        vUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
}
