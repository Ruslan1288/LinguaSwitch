enum HotKeyAction: String, CaseIterable, Codable {
    case switchLayout
    case switchSelectedTextLayout
    case toggleCase
    case titleCase
    case switchClipboardLayout
    case transliterateClipboard
    case spellCheckClipboard
    case showClipboardHistory
    case pasteWithoutFormatting
    case addToAutoReplace
    case showAutoReplaceList
    case openDiary
    case saveSelectedToDiary
    case openPreferences
    case toggleAutoSwitch
    case convertNumberToText
    case transliterateSelected

    var displayName: String {
        switch self {
        case .switchLayout: return "Switch Layout"
        case .switchSelectedTextLayout: return "Switch Selected Text Layout"
        case .toggleCase: return "Toggle Case"
        case .titleCase: return "Title Case"
        case .switchClipboardLayout: return "Switch Clipboard Layout"
        case .transliterateClipboard: return "Transliterate Clipboard"
        case .spellCheckClipboard: return "Spell Check Clipboard"
        case .showClipboardHistory: return "Show Clipboard History"
        case .pasteWithoutFormatting: return "Paste Without Formatting"
        case .addToAutoReplace: return "Add to Auto-Replace"
        case .showAutoReplaceList: return "Show Auto-Replace List"
        case .openDiary: return "Open Diary"
        case .saveSelectedToDiary: return "Save Selected to Diary"
        case .openPreferences: return "Open Preferences"
        case .toggleAutoSwitch: return "Toggle Auto-Switch"
        case .convertNumberToText: return "Convert Number to Text"
        case .transliterateSelected: return "Transliterate Selected"
        }
    }
}
