import AppKit
import CoreGraphics

/// Collects diagnostic information and writes it to a log file.
/// Testers can copy the report and send it for debugging.
class DiagnosticsHelper {

    static let logFileURL: URL = {
        let dir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Logs/LinguaSwitch", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("app.log")
    }()

    // MARK: - Logging

    static func log(_ message: String) {
        let line = "[\(timestamp())] \(message)\n"
        print("[LinguaSwitch] \(message)")
        guard let data = line.data(using: .utf8) else { return }
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            if let handle = try? FileHandle(forWritingTo: logFileURL) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        } else {
            try? data.write(to: logFileURL)
        }
    }

    private static func timestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return f.string(from: Date())
    }

    // MARK: - Report

    static func report(eventMonitor: EventMonitor?) -> String {
        let ax    = AXIsProcessTrusted()
        let im    = CGPreflightListenEventAccess()
        let post  = CGPreflightPostEventAccess()
        let tapOK = eventMonitor?.isActive ?? false
        let evOK  = eventMonitor?.eventsReceived ?? false

        let quarantine: String = {
            let path = Bundle.main.bundleURL.path
            let task = Process()
            task.launchPath = "/usr/bin/xattr"
            task.arguments = ["-l", path]
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            try? task.run()
            task.waitUntilExit()
            let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            return out.contains("com.apple.quarantine") ? "YES ⚠️" : "no"
        }()

        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString

        let lines = [
            "=== LinguaSwitch Diagnostics ===",
            "Date:                \(timestamp())",
            "App version:         \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")",
            "macOS:               \(osVersion)",
            "Bundle path:         \(Bundle.main.bundleURL.path)",
            "Quarantine xattr:    \(quarantine)",
            "",
            "--- Permissions ---",
            "AXIsProcessTrusted:            \(ax    ? "true ✅" : "false ❌")",
            "CGPreflightListenEventAccess:  \(im    ? "true ✅" : "false ❌")",
            "CGPreflightPostEventAccess:    \(post  ? "true ✅" : "false ❌")",
            "",
            "--- EventTap ---",
            "tap isActive:        \(tapOK ? "true ✅" : "false ❌")",
            "events received:     \(evOK  ? "true ✅" : "false ❌  ← Input Monitoring likely blocked")",
            "",
            "Log file: \(logFileURL.path)",
            "================================",
        ]
        return lines.joined(separator: "\n")
    }

    static func copyReportToClipboard(eventMonitor: EventMonitor?) {
        let text = report(eventMonitor: eventMonitor)
        log("Diagnostics copied:\n\(text)")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    static func showReportAlert(eventMonitor: EventMonitor?) {
        let text = report(eventMonitor: eventMonitor)
        copyReportToClipboard(eventMonitor: eventMonitor)
        let alert = NSAlert()
        alert.messageText = "LinguaSwitch Diagnostics"
        alert.informativeText = text + "\n\n✅ Copied to clipboard"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Show Log File")
        if alert.runModal() == .alertSecondButtonReturn {
            NSWorkspace.shared.activateFileViewerSelecting([logFileURL])
        }
    }
}
