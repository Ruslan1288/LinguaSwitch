import AppKit
import ApplicationServices
import CoreGraphics

class AccessibilityHelper {
    static func isAccessibilityGranted() -> Bool {
        return AXIsProcessTrusted()
    }

    static func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    static func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    static func isInputMonitoringGranted() -> Bool {
        CGPreflightListenEventAccess()
    }

    static func requestInputMonitoring() {
        CGRequestListenEventAccess()
    }

    static func isPostEventGranted() -> Bool {
        CGPreflightPostEventAccess()
    }

    static func requestPostEvent() {
        CGRequestPostEventAccess()
    }

    static func openInputMonitoringSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
            NSWorkspace.shared.open(url)
        }
    }

    static func allPermissionsGranted() -> Bool {
        isAccessibilityGranted() && isInputMonitoringGranted()
    }
}
