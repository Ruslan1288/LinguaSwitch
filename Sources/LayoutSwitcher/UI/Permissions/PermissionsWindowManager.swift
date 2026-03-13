import AppKit
import SwiftUI

class PermissionsWindowManager {
    static let shared = PermissionsWindowManager()
    private var window: NSWindow?

    func show() {
        if window == nil {
            let hosting = NSHostingController(rootView: PermissionsView())
            let win = NSWindow(contentViewController: hosting)
            win.title = "LinguaSwitch"
            win.styleMask = [.titled, .closable, .fullSizeContentView]
            win.titlebarAppearsTransparent = true
            win.titleVisibility = .hidden
            win.isMovableByWindowBackground = true
            win.level = .floating
            win.center()
            window = win
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        window?.close()
        window = nil
    }
}
