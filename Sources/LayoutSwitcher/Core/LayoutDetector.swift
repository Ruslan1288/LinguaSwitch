import Foundation

class LayoutDetector {
    static let shared = LayoutDetector()

    var dictionaryWeight: Double = 0.6
    var ngramWeight: Double     = 0.4
    var switchThreshold: Double = 0.15

    private init() {}

    // MARK: - Language Detection

    func detectLanguage(of word: String) -> Language? {
        let lower = word.lowercased()
        let hasCyrillic = lower.unicodeScalars.contains { $0.value >= 0x0400 && $0.value <= 0x04FF }
        let hasLatin    = lower.unicodeScalars.contains { $0.value >= 0x0061 && $0.value <= 0x007A }

        if hasCyrillic {
            return .ukrainian
        } else if hasLatin {
            if existsInLanguage(lower, language: .english) { return .english }
            if let detection = NGramAnalyzer.shared.detectLanguage(of: lower),
               detection.confidence > 0.6 {
                return detection.language
            }
            return .english
        }
        return nil
    }

    func existsInLanguage(_ word: String, language: Language) -> Bool {
        DictionaryDatabase.shared.contains(word: word.lowercased(), language: language.rawValue)
    }

    // MARK: - Weighted Scoring

    func scoreLanguage(_ word: String, as language: Language) -> Double {
        let lower = word.lowercased()
        let dictScore: Double = existsInLanguage(lower, language: language) ? 1.0 : 0.0
        let ngramScore = normalizedNgramScore(lower, language: language)
        return dictScore * dictionaryWeight + ngramScore * ngramWeight
    }

    func shouldSwitch(word: String, from currentLanguage: Language, to targetLanguage: Language) -> Bool {
        let currentScore = scoreLanguage(word, as: currentLanguage)
        let targetScore  = scoreLanguage(word, as: targetLanguage)
        return targetScore - currentScore > switchThreshold
    }

    private func normalizedNgramScore(_ text: String, language: Language) -> Double {
        let raw = NGramAnalyzer.shared.score(text: text, language: language)
        return min(raw / 20.0, 1.0)
    }
}
