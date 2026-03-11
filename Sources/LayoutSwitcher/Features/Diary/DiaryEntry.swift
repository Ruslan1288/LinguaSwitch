import Foundation

struct DiaryEntry: Codable {
    let timestamp: Date
    let appBundleID: String
    let appName: String
    let text: String
}
