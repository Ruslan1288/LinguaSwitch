import SwiftUI
import ServiceManagement

struct GeneralTabView: View {
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) { val in
                        if val { try? SMAppService.mainApp.register() }
                        else { try? SMAppService.mainApp.unregister() }
                    }
                Toggle("Show in Menu Bar", isOn: $settings.showInMenuBar)
            }
            Section("Indicator") {
                Toggle("Show Floating Indicator", isOn: $settings.showFloatingIndicator)
                HStack {
                    Text("Auto-hide Delay")
                    Slider(value: $settings.autoHideIndicatorDelay, in: 0.5...5.0, step: 0.5)
                    Text("\(settings.autoHideIndicatorDelay, specifier: "%.1f")s")
                }
                Toggle("Change Color on Typo", isOn: $settings.changeIndicatorColorOnTypo)
            }
            Section("Switching") {
                Toggle("Auto-Switch Enabled", isOn: $settings.autoSwitchEnabled)
                Toggle("Fix Double Caps (THis → This)", isOn: $settings.fixDoubleCaps)
                Toggle("Watch CapsLock", isOn: $settings.watchCapsLock)
                Toggle("Show Layout in Status Bar", isOn: $settings.showLayoutInStatusBar)
            }
        }
        .padding()
    }
}
