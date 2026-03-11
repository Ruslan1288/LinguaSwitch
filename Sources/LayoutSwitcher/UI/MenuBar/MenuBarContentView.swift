import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var state: MenuBarState

    var body: some View {
        let sources   = InputSourceHelper.availableInputSourceInfos()
        let currentID = InputSourceHelper.currentInputSourceID() ?? ""

        ForEach(sources) { info in
            Button(info.id == currentID ? "✓  \(info.name)" : "    \(info.name)") {
                InputSourceHelper.selectInputSource(id: info.id)
            }
        }

        Divider()

        Toggle("Auto-Switch", isOn: $state.autoSwitchEnabled)
        Toggle("Sound Effects", isOn: $state.soundEnabled)

        Divider()

        Button("Preferences...") {
            PreferencesWindowManager.shared.show()
        }
        .keyboardShortcut(",", modifiers: .command)

        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
