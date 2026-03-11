import Combine
import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    private let defaults = UserDefaults(suiteName: "com.layoutswitcher")!

    @Published var launchAtLogin: Bool { didSet { defaults.set(launchAtLogin, forKey: "launchAtLogin") } }
    @Published var showInMenuBar: Bool { didSet { defaults.set(showInMenuBar, forKey: "showInMenuBar") } }
    @Published var showFloatingIndicator: Bool { didSet { defaults.set(showFloatingIndicator, forKey: "showFloatingIndicator") } }
    @Published var autoHideIndicatorDelay: Double { didSet { defaults.set(autoHideIndicatorDelay, forKey: "autoHideIndicatorDelay") } }
    @Published var changeIndicatorColorOnTypo: Bool { didSet { defaults.set(changeIndicatorColorOnTypo, forKey: "changeIndicatorColorOnTypo") } }
    @Published var autoSwitchEnabled: Bool { didSet { defaults.set(autoSwitchEnabled, forKey: "autoSwitchEnabled") } }
    @Published var switchOnDoubleSpaceComma: Bool { didSet { defaults.set(switchOnDoubleSpaceComma, forKey: "switchOnDoubleSpaceComma") } }
    @Published var fixDoubleCaps: Bool { didSet { defaults.set(fixDoubleCaps, forKey: "fixDoubleCaps") } }
    @Published var watchCapsLock: Bool { didSet { defaults.set(watchCapsLock, forKey: "watchCapsLock") } }
    @Published var switchPasswordFields: Bool { didSet { defaults.set(switchPasswordFields, forKey: "switchPasswordFields") } }
    @Published var showLayoutInStatusBar: Bool { didSet { defaults.set(showLayoutInStatusBar, forKey: "showLayoutInStatusBar") } }
    @Published var soundEnabled: Bool { didSet { defaults.set(soundEnabled, forKey: "soundEnabled") } }
    @Published var diaryEnabled: Bool { didSet { defaults.set(diaryEnabled, forKey: "diaryEnabled") } }
    @Published var diaryTrackClipboard: Bool { didSet { defaults.set(diaryTrackClipboard, forKey: "diaryTrackClipboard") } }
    @Published var diaryKeepDaysCount: Int { didSet { defaults.set(diaryKeepDaysCount, forKey: "diaryKeepDaysCount") } }
    @Published var diaryPassword: String { didSet { defaults.set(diaryPassword, forKey: "diaryPassword") } }
    @Published var diaryExcludedApps: [String] { didSet { defaults.set(diaryExcludedApps, forKey: "diaryExcludedApps") } }
    @Published var primaryLayouts: [Language]
    @Published var excludedApps: [ExcludedApp] {
        didSet {
            if let data = try? JSONEncoder().encode(excludedApps) {
                defaults.set(data, forKey: "excludedApps")
            }
        }
    }

    private init() {
        launchAtLogin = defaults.object(forKey: "launchAtLogin") == nil ? true : defaults.bool(forKey: "launchAtLogin")
        showInMenuBar = defaults.object(forKey: "showInMenuBar") == nil ? true : defaults.bool(forKey: "showInMenuBar")
        showFloatingIndicator = defaults.object(forKey: "showFloatingIndicator") == nil ? true : defaults.bool(forKey: "showFloatingIndicator")
        autoHideIndicatorDelay = defaults.object(forKey: "autoHideIndicatorDelay") == nil ? 1.5 : defaults.double(forKey: "autoHideIndicatorDelay")
        changeIndicatorColorOnTypo = defaults.object(forKey: "changeIndicatorColorOnTypo") == nil ? true : defaults.bool(forKey: "changeIndicatorColorOnTypo")
        autoSwitchEnabled = defaults.object(forKey: "autoSwitchEnabled") == nil ? true : defaults.bool(forKey: "autoSwitchEnabled")
        switchOnDoubleSpaceComma = defaults.bool(forKey: "switchOnDoubleSpaceComma")
        fixDoubleCaps = defaults.object(forKey: "fixDoubleCaps") == nil ? true : defaults.bool(forKey: "fixDoubleCaps")
        watchCapsLock = defaults.object(forKey: "watchCapsLock") == nil ? true : defaults.bool(forKey: "watchCapsLock")
        switchPasswordFields = defaults.bool(forKey: "switchPasswordFields")
        showLayoutInStatusBar = defaults.object(forKey: "showLayoutInStatusBar") == nil ? true : defaults.bool(forKey: "showLayoutInStatusBar")
        soundEnabled = defaults.object(forKey: "soundEnabled") == nil ? true : defaults.bool(forKey: "soundEnabled")
        diaryEnabled = defaults.bool(forKey: "diaryEnabled")
        diaryTrackClipboard = defaults.bool(forKey: "diaryTrackClipboard")
        diaryKeepDaysCount = defaults.object(forKey: "diaryKeepDaysCount") == nil ? 30 : defaults.integer(forKey: "diaryKeepDaysCount")
        diaryPassword = defaults.string(forKey: "diaryPassword") ?? ""
        diaryExcludedApps = (defaults.array(forKey: "diaryExcludedApps") as? [String]) ?? ["com.apple.keychainaccess"]
        primaryLayouts = [.english, .ukrainian]

        if let data = defaults.data(forKey: "excludedApps"),
           let apps = try? JSONDecoder().decode([ExcludedApp].self, from: data) {
            excludedApps = apps
        } else {
            excludedApps = [
                ExcludedApp(bundleID: "com.agilebits.onepassword7", name: "1Password"),
                ExcludedApp(bundleID: "com.bitwarden.desktop", name: "Bitwarden"),
                ExcludedApp(bundleID: "com.apple.keychainaccess", name: "Keychain Access")
            ]
        }
    }
}

struct ExcludedApp: Codable, Identifiable {
    let id: UUID
    let bundleID: String
    let name: String
    var iconData: Data?

    init(id: UUID = UUID(), bundleID: String, name: String, iconData: Data? = nil) {
        self.id = id
        self.bundleID = bundleID
        self.name = name
        self.iconData = iconData
    }
}
