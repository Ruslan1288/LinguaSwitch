import SwiftUI

@main
struct LayoutSwitcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var menuBarState = MenuBarState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(state: menuBarState)
        } label: {
            Text(menuBarState.autoSwitchEnabled
                 ? menuBarState.layoutName
                 : "\(menuBarState.layoutName)✕")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            PreferencesWindow()
        }
    }
}
