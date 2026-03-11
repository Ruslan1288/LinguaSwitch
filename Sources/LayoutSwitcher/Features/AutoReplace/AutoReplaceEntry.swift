import Foundation

struct AutoReplaceEntry: Codable, Identifiable {
    let id: UUID
    var abbreviation: String
    var replacement: String
    var caseSensitive: Bool
    var triggerOnTab: Bool
    var triggerOnReturn: Bool
    var triggerOnSpace: Bool

    init(abbreviation: String, replacement: String, caseSensitive: Bool = false,
         triggerOnTab: Bool = true, triggerOnReturn: Bool = true, triggerOnSpace: Bool = false) {
        self.id = UUID()
        self.abbreviation = abbreviation
        self.replacement = replacement
        self.caseSensitive = caseSensitive
        self.triggerOnTab = triggerOnTab
        self.triggerOnReturn = triggerOnReturn
        self.triggerOnSpace = triggerOnSpace
    }
}
