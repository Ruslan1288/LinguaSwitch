import Foundation

/// Looks up a localized string from the app's module bundle.
/// Falls back to the key itself if no translation is found.
func L(_ key: String) -> String {
    Bundle.module.localizedString(forKey: key, value: key, table: "Localizable")
}
