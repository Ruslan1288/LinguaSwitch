import Foundation

class StatsManager {
    static let shared = StatsManager()

    private let defaults = UserDefaults(suiteName: "com.layoutswitcher")!

    private(set) var autoSwitchCount: Int  { didSet { save() } }
    private(set) var manualSwitchCount: Int { didSet { save() } }
    private(set) var appSwitchCounts: [String: Int] { didSet { save() } }

    private init() {
        autoSwitchCount   = defaults.integer(forKey: "stats.autoSwitchCount")
        manualSwitchCount = defaults.integer(forKey: "stats.manualSwitchCount")
        appSwitchCounts   = (defaults.dictionary(forKey: "stats.appSwitchCounts") as? [String: Int]) ?? [:]
    }

    func recordAutoSwitch(appName: String) {
        autoSwitchCount += 1
        appSwitchCounts[appName, default: 0] += 1
    }

    func recordManualSwitch() {
        manualSwitchCount += 1
    }

    func reset() {
        autoSwitchCount   = 0
        manualSwitchCount = 0
        appSwitchCounts   = [:]
    }

    func topApps(limit: Int = 5) -> [AppStat] {
        appSwitchCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { AppStat(name: $0.key, count: $0.value) }
    }

    private func save() {
        defaults.set(autoSwitchCount,   forKey: "stats.autoSwitchCount")
        defaults.set(manualSwitchCount, forKey: "stats.manualSwitchCount")
        defaults.set(appSwitchCounts,   forKey: "stats.appSwitchCounts")
    }
}
