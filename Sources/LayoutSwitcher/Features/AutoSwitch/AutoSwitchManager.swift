import AppKit

private extension String {
    func titleCased() -> String {
        self.components(separatedBy: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }
}

class AutoSwitchManager {
    static let shared = AutoSwitchManager()

    func processWord(_ word: String, triggerKeyCode: Int64 = 49) {
        guard AppSettings.shared.autoSwitchEnabled else { return }
        guard word.count >= 3 else { return }
        let cleanWord = word.filter { $0.isLetter }
        guard cleanWord.count >= 3 else { return }
        guard !SwitchRulesManager.shared.isException(cleanWord) else { return }

        let currentLang = currentLanguage()

        // Fast path: word is confidently in current language → no switch
        let currentScore = LayoutDetector.shared.scoreLanguage(cleanWord, as: currentLang)
        if currentScore >= LayoutDetector.shared.switchThreshold * 2 { return }

        for targetLang in AppSettings.shared.primaryLayouts where targetLang != currentLang {
            let converted = TextConverter.shared.convert(cleanWord, from: currentLang, to: targetLang)
            if LayoutDetector.shared.shouldSwitch(word: converted, from: currentLang, to: targetLang) {
                let suffix = triggerSuffix(for: triggerKeyCode)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    // +1 extra backspace to also delete the trigger character (space/punctuation)
                    LayoutSwitcherCore.shared.replaceWord(cleanWord, with: converted + suffix, extraBackspaces: 1)
                    // Switch the actual keyboard layout so next words are typed in the correct layout
                    InputSourceHelper.switchInputSource(to: targetLang)
                    SoundManager.shared.play(.autoSwitch)
                    let appName = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
                    StatsManager.shared.recordAutoSwitch(appName: appName)
                    if AppSettings.shared.showFloatingIndicator {
                        FloatingIndicatorWindow.shared.show("→ \(targetLang.shortName)")
                    }
                }
                return
            }
        }
    }

    /// Returns the character to re-type after replacement for word-boundary triggers.
    private func triggerSuffix(for keyCode: Int64) -> String {
        switch keyCode {
        case 49: return " "   // Space
        case 47: return "."   // Period
        case 43: return ","   // Comma
        case 41: return ";"   // Semicolon
        case 39: return "'"   // Apostrophe
        default: return ""    // Return, Tab — don't re-type
        }
    }

    /// Manually convert the last typed word to the other layout.
    /// Uses ⌥⇧← to select the word, reads via clipboard, converts, types back.
    func convertLastWord() {
        let currentLang = currentLanguage()
        guard let targetLang = AppSettings.shared.primaryLayouts.first(where: { $0 != currentLang }) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let pasteboard = NSPasteboard.general
            let savedClipboard = pasteboard.string(forType: .string)

            pasteboard.clearContents()

            // Select word before cursor
            LayoutSwitcherCore.shared.selectPreviousWord()
            Thread.sleep(forTimeInterval: 0.08)

            // Copy selection
            LayoutSwitcherCore.shared.transformSelectedText { selected in
                guard !selected.isEmpty else { return selected }
                return TextConverter.shared.convert(selected, from: currentLang, to: targetLang)
            }

            // Restore clipboard after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                pasteboard.clearContents()
                if let saved = savedClipboard {
                    pasteboard.setString(saved, forType: .string)
                }
            }

            InputSourceHelper.switchInputSource(to: targetLang)
            SoundManager.shared.play(.autoSwitch)
            if AppSettings.shared.showFloatingIndicator {
                FloatingIndicatorWindow.shared.show("→ \(targetLang.shortName)")
            }
        }
    }

    func switchLayoutManually() {
        InputSourceHelper.switchToNextInputSource()
        StatsManager.shared.recordManualSwitch()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let name = InputSourceHelper.inputSourceDisplayName()
            if AppSettings.shared.showFloatingIndicator {
                FloatingIndicatorWindow.shared.show(name)
            }
            SoundManager.shared.play(.manualSwitch)
        }
    }

    /// Cycles case of selected text (or last word): lowercase → UPPERCASE → Title Case → lowercase…
    func cycleCase() {
        LayoutSwitcherCore.shared.transformSelectedText { text in
            guard !text.isEmpty else { return text }
            if text == text.lowercased() {
                return text.uppercased()
            } else if text == text.uppercased() {
                return text.titleCased()
            } else {
                return text.lowercased()
            }
        }
    }

    func switchSelectedTextLayout() {
        let currentLang = currentLanguage()
        let targetLangs = AppSettings.shared.primaryLayouts.filter { $0 != currentLang }
        guard let targetLang = targetLangs.first else { return }
        LayoutSwitcherCore.shared.transformSelectedText { text in
            TextConverter.shared.convert(text, from: currentLang, to: targetLang)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            InputSourceHelper.switchToNextInputSource()
        }
    }

    private func currentLanguage() -> Language {
        switch InputSourceHelper.inputSourceDisplayName() {
        case "UK": return .ukrainian
        default:   return .english
        }
    }
}
