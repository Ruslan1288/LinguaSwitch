import Foundation
import Combine

class MenuBarState: ObservableObject {
    @Published var layoutName: String = ""
    @Published var autoSwitchEnabled: Bool
    @Published var soundEnabled: Bool

    private var cancellables = Set<AnyCancellable>()
    private var inputSourceObserver: Any?

    init() {
        autoSwitchEnabled = AppSettings.shared.autoSwitchEnabled
        soundEnabled      = AppSettings.shared.soundEnabled
        updateLayout()
        observeInputSource()

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

    deinit {
        if let obs = inputSourceObserver {
            DistributedNotificationCenter.default().removeObserver(obs)
        }
    }
}
