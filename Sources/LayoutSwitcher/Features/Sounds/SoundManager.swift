import AppKit

enum SoundEvent: String, CaseIterable {
    case autoSwitch, manualSwitch, typoDetected

    var displayName: String {
        switch self {
        case .autoSwitch:   return "Auto Switch"
        case .manualSwitch: return "Manual Switch"
        case .typoDetected: return "Typo Detected"
        }
    }

    var defaultSoundName: NSSound.Name {
        switch self {
        case .autoSwitch:   return "Tink"   // subtle, non-intrusive
        case .manualSwitch: return "Pop"
        case .typoDetected: return "Funk"
        }
    }
}

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    @Published var eventEnabled: [String: Bool] = Dictionary(
        uniqueKeysWithValues: SoundEvent.allCases.map { ($0.rawValue, true) }
    )

    func play(_ event: SoundEvent) {
        guard AppSettings.shared.soundEnabled else { return }
        guard eventEnabled[event.rawValue] == true else { return }
        NSSound(named: event.defaultSoundName)?.play()
    }

    func preview(_ event: SoundEvent) {
        NSSound(named: event.defaultSoundName)?.play()
    }
}
