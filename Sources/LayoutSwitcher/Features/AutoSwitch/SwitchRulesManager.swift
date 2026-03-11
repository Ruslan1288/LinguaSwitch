import Combine
import Foundation

class SwitchRulesManager: ObservableObject {
    static let shared = SwitchRulesManager()
    @Published var exceptions: [String] = []
    private let key = "switchExceptions"

    private init() {
        exceptions = (UserDefaults.standard.array(forKey: key) as? [String]) ?? []
    }

    func isException(_ word: String) -> Bool {
        exceptions.contains(word.lowercased())
    }

    func add(_ word: String) {
        let lower = word.lowercased().trimmingCharacters(in: .whitespaces)
        guard !lower.isEmpty, !exceptions.contains(lower) else { return }
        exceptions.append(lower)
        save()
    }

    func remove(at offsets: IndexSet) {
        exceptions.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        UserDefaults.standard.set(exceptions, forKey: key)
    }
}
