import AppKit
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?

    var eventMonitor: EventMonitor?
    private var permissionsTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        NSApp.setActivationPolicy(.accessory)

        removeQuarantineAttribute()

        // Always request both permissions upfront.
        // CGRequestListenEventAccess() triggers the TCC dialog on macOS 15/16 even when
        // CGPreflightListenEventAccess() mistakenly returns true for an un-granted app.
        AccessibilityHelper.requestInputMonitoring()
        AccessibilityHelper.requestPostEvent()

        if AccessibilityHelper.isAccessibilityGranted() {
            startCoreServices()
        } else {
            AccessibilityHelper.requestAccessibility()
            showPermissionsOnboarding()
            startPermissionsPolling()
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

    private func showPermissionsOnboarding() {
        let alert = NSAlert()
        alert.messageText = L("alert.permissions_title")
        alert.informativeText = L("alert.permissions_body")
        alert.addButton(withTitle: L("alert.open_accessibility"))
        alert.addButton(withTitle: L("alert.later"))
        if alert.runModal() == .alertFirstButtonReturn {
            if !AccessibilityHelper.isAccessibilityGranted() {
                AccessibilityHelper.openAccessibilitySettings()
            } else {
                AccessibilityHelper.openInputMonitoringSettings()
            }
        }
    }

    private func startPermissionsPolling() {
        permissionsTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            if AccessibilityHelper.allPermissionsGranted() {
                timer.invalidate()
                self?.permissionsTimer = nil
                self?.showRestartRequired()
            }
        }
    }

    private func showRestartRequired() {
        let alert = NSAlert()
        alert.messageText = L("alert.restart_title")
        alert.informativeText = L("alert.restart_body")
        alert.addButton(withTitle: L("alert.restart_now"))
        alert.addButton(withTitle: L("alert.later"))
        if alert.runModal() == .alertFirstButtonReturn {
            relaunch()
        }
    }

    /// Removes the com.apple.quarantine xattr that prevents CGEventTap from working
    /// on freshly downloaded/installed apps. Safe to call even if not quarantined.
    private func removeQuarantineAttribute() {
        let path = Bundle.main.bundleURL.path
        let task = Process()
        task.launchPath = "/usr/bin/xattr"
        task.arguments = ["-dr", "com.apple.quarantine", path]
        try? task.run()
    }

    /// Called from menu bar when EventTap is inactive. Tries to restart monitoring
    /// without a full app relaunch. Falls back to relaunch if tap creation fails again.
    func retryEventTap() {
        eventMonitor?.stop()
        eventMonitor = nil
        // Give the old tap thread a moment to exit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.startCoreServices()
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
