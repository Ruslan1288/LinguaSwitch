import AppKit
import SwiftUI

class PreferencesWindowManager {
    static let shared = PreferencesWindowManager()
    private var window: NSWindow?

    func show() {
        NSLog("[Prefs] show() called")
        if window == nil {
            let hosting = NSHostingController(rootView: PreferencesWindow())
            let win = NSWindow(contentViewController: hosting)
            win.title = "LinguaSwitch"
            win.styleMask = [.titled, .closable, .miniaturizable]
            win.setContentSize(NSSize(width: 560, height: 480))
            win.center()
            win.setFrameAutosaveName("PreferencesWindow")
            window = win
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
