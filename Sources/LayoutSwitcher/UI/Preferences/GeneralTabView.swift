import SwiftUI
import ServiceManagement

struct GeneralTabView: View {
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PageTitle(title: "General")

                SectionLabel(title: "Startup")
                PrefsGroupBox {
                    PrefsToggleRow(
                        icon: "sunrise.fill", iconColor: .orange,
                        title: "Launch at Login",
                        subtitle: "Start LinguaSwitch automatically on login",
                        isOn: $settings.launchAtLogin
                    )
                    .onChange(of: settings.launchAtLogin) { val in
                        if val { try? SMAppService.mainApp.register() }
                        else   { try? SMAppService.mainApp.unregister() }
                    }
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "menubar.rectangle", iconColor: .blue,
                        title: "Show in Menu Bar",
                        isOn: $settings.showInMenuBar
                    )
                }

                SectionLabel(title: "Floating Indicator")
                PrefsGroupBox {
                    PrefsToggleRow(
                        icon: "bubble.left.fill", iconColor: .purple,
                        title: "Show Floating Indicator",
                        subtitle: "Displays current layout near the cursor",
                        isOn: $settings.showFloatingIndicator
                    )
                    InsetDivider()
                    PrefsSliderRow(
                        icon: "timer", iconColor: Color(red: 0.5, green: 0.5, blue: 0.9),
                        title: "Auto-hide Delay",
                        value: $settings.autoHideIndicatorDelay,
                        range: 0.5...5.0, step: 0.5, unit: "s"
                    )
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "paintpalette.fill", iconColor: .red,
                        title: "Highlight Typos",
                        subtitle: "Changes indicator color when a typo is detected",
                        isOn: $settings.changeIndicatorColorOnTypo
                    )
                }

                SectionLabel(title: "Auto-Switch")
                PrefsGroupBox {
                    PrefsToggleRow(
                        icon: "arrow.left.arrow.right", iconColor: Color(red: 0.2, green: 0.78, blue: 0.55),
                        title: "Auto-Switch Enabled",
                        subtitle: "Automatically detects and converts mistyped words",
                        isOn: $settings.autoSwitchEnabled
                    )
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "textformat", iconColor: Color(red: 0.9, green: 0.5, blue: 0.2),
                        title: "Fix Double Caps",
                        subtitle: "THis → This",
                        isOn: $settings.fixDoubleCaps
                    )
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "capslock.fill", iconColor: Color(red: 0.6, green: 0.4, blue: 0.9),
                        title: "Watch CapsLock",
                        isOn: $settings.watchCapsLock
                    )
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "rectangle.topthird.inset.filled", iconColor: .gray,
                        title: "Show Layout in Status Bar",
                        isOn: $settings.showLayoutInStatusBar
                    )
                }

                Spacer(minLength: 20)
            }
            .padding(20)
        }
    }
}
