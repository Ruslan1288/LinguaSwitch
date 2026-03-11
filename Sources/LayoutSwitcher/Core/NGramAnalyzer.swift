import Foundation

/// Analyzes character n-gram frequencies to detect language.
/// Useful for words not present in the dictionary.
class NGramAnalyzer {
    static let shared = NGramAnalyzer()

    // MARK: - Frequency Tables

    // Top English bigrams with normalized frequencies (per 1000 bigrams, approximate)
    private let enBigrams: [String: Double] = [
        "th": 35.6, "he": 30.7, "in": 24.3, "er": 20.5, "an": 19.9,
        "re": 18.5, "on": 17.6, "en": 17.5, "at": 14.9, "es": 14.5,
        "ed": 14.3, "te": 13.5, "ti": 13.4, "or": 12.8, "it": 12.4,
        "ng": 11.8, "is": 11.3, "al": 10.9, "ar": 10.7, "st": 10.5,
        "to": 10.4, "nt": 10.4, "ha": 9.3,  "nd": 9.3,  "ou": 8.7,
        "ea": 8.7,  "hi": 8.7,  "le": 8.3,  "se": 8.3,  "of": 7.6,
        "ve": 7.2,  "co": 7.1,  "me": 7.1,  "de": 6.9,  "ro": 6.7,
        "li": 6.6,  "ri": 6.5,  "io": 6.4,  "ss": 6.1,  "si": 6.0
    ]

    // Top Ukrainian bigrams (Cyrillic) with normalized frequencies
    private let ukBigrams: [String: Double] = [
        "ст": 18.5, "пр": 20.0, "на": 18.0, "ні": 17.5, "та": 16.5,
        "ко": 16.0, "ро": 15.5, "ти": 15.0, "ри": 14.5, "ор": 14.0,
        "ен": 13.0, "не": 12.5, "ос": 12.0, "ар": 11.5, "ра": 11.0,
        "за": 10.5, "ан": 10.0, "ій": 9.0,  "ви": 8.5,  "по": 8.0,
        "го": 7.5,  "де": 7.0,  "ли": 7.0,  "те": 6.5,  "ди": 6.0,
        "ло": 5.5,  "ть": 5.5,  "во": 5.0,  "ле": 5.0,  "ми": 4.8,
        "кр": 4.5,  "тр": 4.0,  "до": 4.0,  "ла": 3.8,  "со": 3.7,
        "ін": 3.5,  "що": 13.5, "ою": 9.5,  "но": 8.0,  "ва": 7.2
    ]

    // Top English trigrams
    private let enTrigrams: [String: Double] = [
        "the": 35.1, "and": 15.9, "ing": 11.5, "ion": 8.3, "tio": 7.7,
        "ent": 7.0,  "ati": 6.5,  "for": 6.3,  "her": 6.0, "ter": 5.9,
        "hat": 5.7,  "tha": 5.5,  "ere": 5.4,  "con": 5.2, "ons": 5.1,
        "est": 5.0,  "all": 4.8,  "int": 4.8,  "ith": 4.7, "rea": 4.6,
        "ate": 4.5,  "his": 4.4,  "not": 4.3,  "res": 4.2, "ver": 4.1
    ]

    // Top Ukrainian trigrams (Cyrillic)
    private let ukTrigrams: [String: Double] = [
        "про": 15.0, "ств": 13.0, "ого": 12.5, "ати": 11.5, "при": 9.5,
        "ний": 10.5, "нні": 10.0, "від": 8.0,  "між": 7.5,  "час": 7.0,
        "ції": 6.5,  "пра": 5.5,  "ста": 5.3,  "вно": 5.0,  "яко": 4.8,
        "для": 4.5,  "але": 4.3,  "тіл": 4.0,  "нас": 3.8,  "має": 3.5,
        "або": 4.2,  "все": 3.9,  "так": 4.1,  "які": 8.5,  "ден": 5.8
    ]

    private init() {}

    // MARK: - Scoring

    /// Returns a language score for the given text.
    /// Higher score = text is more likely to be in this language.
    func score(text: String, language: Language) -> Double {
        let lower = text.lowercased()
        guard lower.count >= 2 else { return 0.0 }

        let bigrams = language == .english ? enBigrams : ukBigrams
        let trigrams = language == .english ? enTrigrams : ukTrigrams
        let chars = Array(lower)

        var bigramTotal = 0.0
        var bigramMatches = 0
        for i in 0..<(chars.count - 1) {
            let key = String(chars[i]) + String(chars[i + 1])
            if let freq = bigrams[key] {
                bigramTotal += freq
                bigramMatches += 1
            }
        }

        var trigramTotal = 0.0
        var trigramMatches = 0
        if chars.count >= 3 {
            for i in 0..<(chars.count - 2) {
                let key = String(chars[i]) + String(chars[i + 1]) + String(chars[i + 2])
                if let freq = trigrams[key] {
                    trigramTotal += freq
                    trigramMatches += 1
                }
            }
        }

        // Normalize by text length so short and long words are comparable
        let n = Double(chars.count)
        let bigramScore = bigramTotal / n
        let trigramScore = trigramTotal / n

        // Trigrams are more discriminative → higher weight
        return bigramScore * 0.4 + trigramScore * 0.6
    }

    /// Returns (language, confidence 0…1) for the best-matching language, or nil if text is too short.
    func detectLanguage(of text: String) -> (language: Language, confidence: Double)? {
        guard text.count >= 3 else { return nil }

        let enScore = score(text: text, language: .english)
        let ukScore = score(text: text, language: .ukrainian)
        let total = enScore + ukScore
        guard total > 0 else { return nil }

        if enScore >= ukScore {
            return (.english, enScore / total)
        } else {
            return (.ukrainian, ukScore / total)
        }
    }
}
