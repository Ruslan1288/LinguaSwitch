import Combine
import Foundation

class AutoReplaceManager: ObservableObject {
    static let shared = AutoReplaceManager()
    @Published var entries: [AutoReplaceEntry] = []
    private let fileURL: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("LayoutSwitcher")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("autoreplace.json")
        load()
    }

    func checkAndReplace(word: String, triggerKeyCode: Int64) {
        // triggerKeyCode: 49=Space, 36=Return, 48=Tab
        for entry in entries {
            let matches = entry.caseSensitive ? word == entry.abbreviation : word.lowercased() == entry.abbreviation.lowercased()
            guard matches else { continue }
            let triggerOk = (triggerKeyCode == 49 && entry.triggerOnSpace) ||
                            (triggerKeyCode == 36 && entry.triggerOnReturn) ||
                            (triggerKeyCode == 48 && entry.triggerOnTab)
            guard triggerOk else { continue }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                LayoutSwitcherCore.shared.replaceWord(word, with: entry.replacement)
                SoundManager.shared.play(.autoSwitch)
            }
            return
        }
    }

    func add(_ entry: AutoReplaceEntry) { entries.append(entry); save() }
    func remove(at offsets: IndexSet) { entries.remove(atOffsets: offsets); save() }
    func update(_ entry: AutoReplaceEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
            save()
        }
    }

    func exportCSV() -> String {
        var csv = "abbreviation,replacement,caseSensitive,triggerOnTab,triggerOnReturn,triggerOnSpace\n"
        for e in entries {
            csv += "\"\(e.abbreviation)\",\"\(e.replacement)\",\(e.caseSensitive),\(e.triggerOnTab),\(e.triggerOnReturn),\(e.triggerOnSpace)\n"
        }
        return csv
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([AutoReplaceEntry].self, from: data) else { return }
        entries = decoded
    }
}
