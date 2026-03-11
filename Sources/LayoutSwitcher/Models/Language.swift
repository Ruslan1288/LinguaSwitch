enum Language: String, CaseIterable, Codable {
    case english = "en"
    case ukrainian = "uk"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .ukrainian: return "Українська"
        }
    }

    var shortName: String { rawValue.uppercased() }
}
