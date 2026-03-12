import Foundation
import Combine

class MenuBarState: ObservableObject {
    @Published var layoutName: String = ""
    @Published var autoSwitchEnabled: Bool
    @Published var soundEnabled: Bool
    @Published var eventTapActive: Bool = true

    private var cancellables = Set<AnyCancellable>()
    private var inputSourceObserver: Any?
    private var tapObserver: Any?

    init() {
        autoSwitchEnabled = AppSettings.shared.autoSwitchEnabled
        soundEnabled      = AppSettings.shared.soundEnabled
        updateLayout()
        observeInputSource()
        observeTapStatus()

        $autoSwitchEnabled
            .dropFirst()
            .sink { AppSettings.shared.autoSwitchEnabled = $0 }
            .store(in: &cancellables)

        $soundEnabled
            .dropFirst()
            .sink { AppSettings.shared.soundEnabled = $0 }
            .store(in: &cancellables)
    }

    func updateLayout() {
        layoutName = InputSourceHelper.inputSourceDisplayName()
    }

    private func observeInputSource() {
        inputSourceObserver = DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.updateLayout() }
    }

    private func observeTapStatus() {
        tapObserver = NotificationCenter.default.addObserver(
            forName: .eventTapStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.eventTapActive = (note.object as? Bool) ?? false
        }
    }

    deinit {
        if let obs = inputSourceObserver {
            DistributedNotificationCenter.default().removeObserver(obs)
        }
        if let obs = tapObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
}
