import SwiftUI
import ServiceManagement

struct GeneralTabView: View {
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PageTitle(title: L("general.title"))

                SectionLabel(title: L("general.startup"))
                PrefsGroupBox {
                    PrefsToggleRow(
                        icon: "sunrise.fill", iconColor: .orange,
                        title: L("general.launch_at_login"),
                        subtitle: L("general.launch_at_login_sub"),
                        isOn: $settings.launchAtLogin
                    )
                    .onChange(of: settings.launchAtLogin) { val in
                        if val { try? SMAppService.mainApp.register() }
                        else   { try? SMAppService.mainApp.unregister() }
                    }
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "menubar.rectangle", iconColor: .blue,
                        title: L("general.show_in_menu_bar"),
                        isOn: $settings.showInMenuBar
                    )
                }

                SectionLabel(title: L("general.floating_indicator"))
                PrefsGroupBox {
                    PrefsToggleRow(
                        icon: "bubble.left.fill", iconColor: .purple,
                        title: L("general.show_floating_indicator"),
                        subtitle: L("general.show_floating_indicator_sub"),
                        isOn: $settings.showFloatingIndicator
                    )
                    InsetDivider()
                    PrefsSliderRow(
                        icon: "timer", iconColor: Color(red: 0.5, green: 0.5, blue: 0.9),
                        title: L("general.autohide_delay"),
                        value: $settings.autoHideIndicatorDelay,
                        range: 0.5...5.0, step: 0.5, unit: "s"
                    )
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "paintpalette.fill", iconColor: .red,
                        title: L("general.highlight_typos"),
                        subtitle: L("general.highlight_typos_sub"),
                        isOn: $settings.changeIndicatorColorOnTypo
                    )
                }

                SectionLabel(title: L("general.autoswitch"))
                PrefsGroupBox {
                    PrefsToggleRow(
                        icon: "arrow.left.arrow.right", iconColor: Color(red: 0.2, green: 0.78, blue: 0.55),
                        title: L("general.autoswitch_enabled"),
                        subtitle: L("general.autoswitch_enabled_sub"),
                        isOn: $settings.autoSwitchEnabled
                    )
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "textformat", iconColor: Color(red: 0.9, green: 0.5, blue: 0.2),
                        title: L("general.fix_double_caps"),
                        subtitle: L("general.fix_double_caps_sub"),
                        isOn: $settings.fixDoubleCaps
                    )
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "capslock.fill", iconColor: Color(red: 0.6, green: 0.4, blue: 0.9),
                        title: L("general.watch_capslock"),
                        isOn: $settings.watchCapsLock
                    )
                    InsetDivider()
                    PrefsToggleRow(
                        icon: "rectangle.topthird.inset.filled", iconColor: .gray,
                        title: L("general.show_layout_in_statusbar"),
                        isOn: $settings.showLayoutInStatusBar
                    )
                }

                SectionLabel(title: L("general.backup_restore"))
                PrefsGroupBox {
                    PrefsButtonRow(
                        icon: "square.and.arrow.up", iconColor: .blue,
                        title: L("general.export_settings"),
                        subtitle: L("general.export_settings_sub")
                    ) {
                        AppSettings.shared.showExportPanel()
                    }
                    InsetDivider()
                    PrefsButtonRow(
                        icon: "square.and.arrow.down", iconColor: Color(red: 0.2, green: 0.7, blue: 0.4),
                        title: L("general.import_settings"),
                        subtitle: L("general.import_settings_sub")
                    ) {
                        AppSettings.shared.showImportPanel()
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(20)
        }
    }
}
