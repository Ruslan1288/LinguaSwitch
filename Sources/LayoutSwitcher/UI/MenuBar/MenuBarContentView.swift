import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var state: MenuBarState

    var body: some View {
        let sources   = InputSourceHelper.availableInputSourceInfos()
        let currentID = InputSourceHelper.currentInputSourceID() ?? ""

        if !state.eventTapActive {
            if AccessibilityHelper.isAccessibilityGranted() {
                // Accessibility is granted but tap still failed (quarantine or other issue).
                // Retry creating the tap — quarantine was removed on launch so this usually works.
                Button("⚠️ Monitoring inactive — click to retry") {
                    AppDelegate.shared?.retryEventTap()
                }
            } else {
                Button("⚠️ Grant Accessibility permission to activate") {
                    AccessibilityHelper.openAccessibilitySettings()
                }
            }
            Divider()
        }

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
