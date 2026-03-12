import AppKit
import SwiftUI

class PreferencesWindowManager {
    static let shared = PreferencesWindowManager()
    private var window: NSWindow?

    func show() {
        if window == nil {
            let hosting = NSHostingController(rootView: PreferencesWindow())
            let win = NSWindow(contentViewController: hosting)
            win.title = "LinguaSwitch"
            win.styleMask = [.titled, .closable, .miniaturizable, .fullSizeContentView]
            win.titlebarAppearsTransparent = true
            win.titleVisibility = .hidden
            win.setContentSize(NSSize(width: 700, height: 500))
            win.isMovableByWindowBackground = true
            win.center()
            win.setFrameAutosaveName("PreferencesWindow")
            window = win
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
