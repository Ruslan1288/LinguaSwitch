import Foundation
import AppKit

class DiaryManager {
    static let shared = DiaryManager()
    private var buffer: [DiaryEntry] = []
    private var flushTimer: Timer?
    private let queue = DispatchQueue(label: "com.layoutswitcher.diary", qos: .background)
    private let diaryDir: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        diaryDir = appSupport.appendingPathComponent("LayoutSwitcher/Diary")
        try? FileManager.default.createDirectory(at: diaryDir, withIntermediateDirectories: true)
    }

    func startAutoFlush() {
        flushTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.flushToDisk()
        }
        RunLoop.main.add(flushTimer!, forMode: .common)
        purgeOldEntries()
    }

    func record(text: String, appName: String = "", bundleID: String = "") {
        guard AppSettings.shared.diaryEnabled else { return }
        let entry = DiaryEntry(
            timestamp: Date(),
            appBundleID: bundleID,
            appName: appName.isEmpty ? (NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown") : appName,
            text: text
        )
        queue.async { [weak self] in self?.buffer.append(entry) }
    }

    func flushToDisk() {
        queue.async { [weak self] in
            guard let self, !self.buffer.isEmpty else { return }
            let toFlush = self.buffer
            self.buffer.removeAll()
            self.write(entries: toFlush)
        }
    }

    private func write(entries: [DiaryEntry]) {
        let grouped = Dictionary(grouping: entries) { entry -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: entry.timestamp)
        }

        for (date, dayEntries) in grouped {
            let fileURL = diaryDir.appendingPathComponent("\(date).rtf")
            var text = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            for entry in dayEntries {
                let time = timeFormatter.string(from: entry.timestamp)
                text += "[\(time)] [\(entry.appName)] \(entry.text)\n"
            }
            try? text.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    func entriesForDate(_ date: Date) -> [DiaryEntry] {
        flushToDisk()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        let fileURL = diaryDir.appendingPathComponent("\(dateStr).rtf")
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { return [] }
        // Parse lines back to entries
        return content.components(separatedBy: "\n").compactMap { line -> DiaryEntry? in
            guard !line.isEmpty else { return nil }
            return DiaryEntry(timestamp: date, appBundleID: "", appName: "", text: line)
        }
    }

    func clearDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fileURL = diaryDir.appendingPathComponent("\(formatter.string(from: date)).rtf")
        try? FileManager.default.removeItem(at: fileURL)
    }

    func availableDates() -> [Date] {
        let files = (try? FileManager.default.contentsOfDirectory(at: diaryDir, includingPropertiesForKeys: nil)) ?? []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return files.compactMap { url in
            let name = url.deletingPathExtension().lastPathComponent
            return formatter.date(from: name)
        }.sorted()
    }

    private func purgeOldEntries() {
        let keepDays = AppSettings.shared.diaryKeepDaysCount
        guard keepDays > 0 else { return }
        let cutoff = Calendar.current.date(byAdding: .day, value: -keepDays, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let files = (try? FileManager.default.contentsOfDirectory(at: diaryDir, includingPropertiesForKeys: nil)) ?? []
        for file in files {
            let name = file.deletingPathExtension().lastPathComponent
            if let date = formatter.date(from: name), date < cutoff {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}
