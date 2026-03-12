import AppKit
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?

    var eventMonitor: EventMonitor?
    private var accessibilityTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        NSApp.setActivationPolicy(.accessory)

        if AccessibilityHelper.isAccessibilityGranted() {
            startCoreServices()
        } else {
            AccessibilityHelper.requestAccessibility()
            showOnboarding()
            startAccessibilityPolling()
        }

        // Launch at login
        if AppSettings.shared.launchAtLogin {
            try? SMAppService.mainApp.register()
        }
    }

    private func startCoreServices() {
        eventMonitor = EventMonitor()
        eventMonitor?.onWord = { word, triggerKeyCode in
            AutoSwitchManager.shared.processWord(word, triggerKeyCode: triggerKeyCode)
        }
        eventMonitor?.onAutoReplace = { word in
            // handled inside EventMonitor on trigger key
        }
        eventMonitor?.start()

        // Clipboard / Diary — out of scope for v1.0, disabled
        // ClipboardManager.shared.startMonitoring()
        // DiaryManager.shared.startAutoFlush()

        // Register hotkeys
        HotKeyCenter.shared.register(keyCode: 49, modifiers: [.option]) {
            AutoSwitchManager.shared.switchLayoutManually()
        }
        HotKeyCenter.shared.register(keyCode: 49, modifiers: [.option, .shift]) {
            AutoSwitchManager.shared.switchSelectedTextLayout()
        }
        // Option+Shift+C — cycle case
        HotKeyCenter.shared.register(keyCode: 8, modifiers: [.option, .shift]) {
            AutoSwitchManager.shared.cycleCase()
        }
        // Option+Z — convert last word manually
        HotKeyCenter.shared.register(keyCode: 6, modifiers: [.option]) {
            AutoSwitchManager.shared.convertLastWord()
        }
    }

    private func showOnboarding() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "LayoutSwitcher needs Accessibility access to monitor and switch keyboard layouts system-wide. Please grant permission in System Settings → Privacy & Security → Accessibility."
        alert.addButton(withTitle: "Open Accessibility Settings")
        alert.addButton(withTitle: "Later")
        if alert.runModal() == .alertFirstButtonReturn {
            AccessibilityHelper.openAccessibilitySettings()
        }
    }

    private func startAccessibilityPolling() {
        accessibilityTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            if AccessibilityHelper.isAccessibilityGranted() {
                timer.invalidate()
                self?.accessibilityTimer = nil
                self?.showRestartRequired()
            }
        }
    }

    private func showRestartRequired() {
        let alert = NSAlert()
        alert.messageText = "Restart Required"
        alert.informativeText = "Accessibility permission was granted. LinguaSwitch needs to restart to activate keyboard monitoring."
        alert.addButton(withTitle: "Restart Now")
        alert.addButton(withTitle: "Later")
        if alert.runModal() == .alertFirstButtonReturn {
            relaunch()
        }
    }

    private func relaunch() {
        let url = Bundle.main.bundleURL
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [url.path]
        task.launch()
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        eventMonitor?.stop()
    }
}
