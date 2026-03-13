import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var state: MenuBarState

    var body: some View {
        let sources   = InputSourceHelper.availableInputSourceInfos()
        let currentID = InputSourceHelper.currentInputSourceID() ?? ""

        if !state.eventTapActive {
            if !AccessibilityHelper.isAccessibilityGranted() {
                Button(L("menu.grant_accessibility")) {
                    AccessibilityHelper.openAccessibilitySettings()
                }
            } else if !AccessibilityHelper.isInputMonitoringGranted() {
                Button(L("menu.grant_input_monitoring")) {
                    AccessibilityHelper.openInputMonitoringSettings()
                }
            } else {
                Button(L("menu.monitoring_inactive_retry")) {
                    AppDelegate.shared?.retryEventTap()
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

        Toggle(L("menu.auto_switch"), isOn: $state.autoSwitchEnabled)
        Toggle(L("menu.sound_effects"), isOn: $state.soundEnabled)

        Divider()

        Button(L("menu.preferences")) {
            PreferencesWindowManager.shared.show()
        }
        .keyboardShortcut(",", modifiers: .command)

        Button(L("menu.copy_diagnostics")) {
            DiagnosticsHelper.showReportAlert(eventMonitor: AppDelegate.shared?.eventMonitor)
        }

        Button(L("menu.quit")) {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
