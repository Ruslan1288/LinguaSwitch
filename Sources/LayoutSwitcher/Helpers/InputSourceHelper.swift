import Carbon
import AppKit

struct InputSourceInfo: Identifiable {
    let id: String   // kTISPropertyInputSourceID
    let name: String // kTISPropertyLocalizedName
}

class InputSourceHelper {
    static func availableInputSourceInfos() -> [InputSourceInfo] {
        availableInputSources().compactMap { src in
            guard let idPtr   = TISGetInputSourceProperty(src, kTISPropertyInputSourceID),
                  let namePtr = TISGetInputSourceProperty(src, kTISPropertyLocalizedName) else { return nil }
            let id   = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue()   as String
            let name = Unmanaged<CFString>.fromOpaque(namePtr).takeUnretainedValue() as String
            return InputSourceInfo(id: id, name: name)
        }
    }

    static func selectInputSource(id: String) {
        for src in availableInputSources() {
            guard let idPtr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) else { continue }
            let srcID = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
            if srcID == id { TISSelectInputSource(src); return }
        }
    }

    static func availableInputSources() -> [TISInputSource] {
        let filter = [kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource!,
                      kTISPropertyInputSourceIsSelectCapable: true] as CFDictionary
        guard let list = TISCreateInputSourceList(filter, false)?.takeRetainedValue() else { return [] }
        let count = CFArrayGetCount(list)
        return (0..<count).compactMap { i in
            guard let ptr = CFArrayGetValueAtIndex(list, i) else { return nil }
            return Unmanaged<TISInputSource>.fromOpaque(ptr).takeUnretainedValue()
        }
    }

    static func currentInputSourceID() -> String? {
        guard let src = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { return nil }
        guard let ptr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) else { return nil }
        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }

    static func switchToNextInputSource() {
        let sources = availableInputSources()
        guard sources.count > 1 else { return }
        guard let currentID = currentInputSourceID() else { return }
        let ids: [String] = sources.compactMap { src in
            guard let ptr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) else { return nil }
            return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
        }
        let idx = ids.firstIndex(of: currentID) ?? 0
        let nextIdx = (idx + 1) % sources.count
        TISSelectInputSource(sources[nextIdx])
    }

    /// Switch to the input source matching the given language.
    /// Uses source ID (e.g. "com.apple.keylayout.Ukrainian-PC") — locale-independent.
    static func switchInputSource(to language: Language) {
        let sources = availableInputSources()
        for src in sources {
            guard let idPtr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID) else { continue }
            let id = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
            switch language {
            case .ukrainian where id.lowercased().contains("ukrainian"):
                TISSelectInputSource(src); return
            case .english where (id.contains("ABC") || id.contains("U.S") || id.contains("English")):
                TISSelectInputSource(src); return
            default: continue
            }
        }
    }

    static func inputSourceDisplayName() -> String {
        guard let src = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { return "??" }
        guard let ptr = TISGetInputSourceProperty(src, kTISPropertyLocalizedName) else { return "??" }
        let name = Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
        if name.localizedCaseInsensitiveContains("Ukrainian") { return "UK" }
        if name.localizedCaseInsensitiveContains("U.S.") || name.localizedCaseInsensitiveContains("English") { return "EN" }
        return String(name.prefix(2)).uppercased()
    }
}
