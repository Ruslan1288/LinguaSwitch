import XCTest
@testable import LayoutSwitcher

final class LayoutSwitcherTests: XCTestCase {

    // MARK: - TextConverter

    func testEnToUkConversion() {
        // "ghbdsn" on QWERTY → "привіт" on Ukrainian layout (s=і, not t=е)
        let result = TextConverter.shared.convert("ghbdsn", from: .english, to: .ukrainian)
        XCTAssertEqual(result, "привіт")
    }

    func testUkToEnRoundTrip() {
        let original = "ghbdsn"
        let toUk = TextConverter.shared.convert(original, from: .english, to: .ukrainian)
        let back = TextConverter.shared.convert(toUk, from: .ukrainian, to: .english)
        XCTAssertEqual(original, back)
    }

    func testEnToRuConversion() {
        let result = TextConverter.shared.convert("ghbdtn", from: .english, to: .russian)
        XCTAssertFalse(result.isEmpty)
    }

    func testNumberToUkrainian() {
        XCTAssertEqual(TextConverter.shared.numberToText(0, language: .ukrainian), "нуль")
        XCTAssertEqual(TextConverter.shared.numberToText(1, language: .ukrainian), "один")
        XCTAssertFalse(TextConverter.shared.numberToText(1234, language: .ukrainian).isEmpty)
        XCTAssertFalse(TextConverter.shared.numberToText(1_000_000, language: .ukrainian).isEmpty)
    }

    func testTransliteration() {
        let result = TextConverter.shared.transliterate("привіт")
        XCTAssertFalse(result.isEmpty)
        XCTAssertFalse(result.unicodeScalars.contains { $0.value >= 0x0400 && $0.value <= 0x04FF })
    }

    // MARK: - NGramAnalyzer: English text detection

    func testNgramEnglishScoreHigherThanUkrainianForEnText() {
        let analyzer = NGramAnalyzer.shared
        let texts = ["the", "english", "hello", "world", "there", "something", "interesting"]
        for text in texts {
            let enScore = analyzer.score(text: text, language: .english)
            let ukScore = analyzer.score(text: text, language: .ukrainian)
            XCTAssertGreaterThan(enScore, ukScore, "EN score should be higher for '\(text)'")
        }
    }

    func testNgramUkrainianScoreHigherThanEnglishForUkText() {
        let analyzer = NGramAnalyzer.shared
        let texts = ["привіт", "стати", "прийти", "ніколи", "такого", "розвиток"]
        for text in texts {
            let ukScore = analyzer.score(text: text, language: .ukrainian)
            let enScore = analyzer.score(text: text, language: .english)
            XCTAssertGreaterThan(ukScore, enScore, "UK score should be higher for '\(text)'")
        }
    }

    func testNgramDetectLanguageEnglish() {
        let analyzer = NGramAnalyzer.shared
        let words = ["interesting", "something", "together", "standing"]
        for word in words {
            let result = analyzer.detectLanguage(of: word)
            XCTAssertNotNil(result, "Should detect language for '\(word)'")
            XCTAssertEqual(result?.language, .english, "Should detect English for '\(word)'")
        }
    }

    func testNgramDetectLanguageUkrainian() {
        let analyzer = NGramAnalyzer.shared
        let words = ["стати", "прийти", "розвиток", "привіт"]
        for word in words {
            let result = analyzer.detectLanguage(of: word)
            XCTAssertNotNil(result, "Should detect language for '\(word)'")
            XCTAssertEqual(result?.language, .ukrainian, "Should detect Ukrainian for '\(word)'")
        }
    }

    func testNgramReturnNilForShortText() {
        let result = NGramAnalyzer.shared.detectLanguage(of: "ab")
        XCTAssertNil(result, "Should not detect language for text shorter than 3 chars")
    }

    // MARK: - NGramAnalyzer: Garbled text detection (wrong layout)
    // "ghbdtn" = "привіт" typed with EN layout active

    func testGarbledUkrainianHasLowEnglishScore() {
        let analyzer = NGramAnalyzer.shared
        // These are Ukrainian words typed on EN layout
        let garbled = ["ghbdtn", "crjhjcnm", "fynhtgjkjubz"]
        for word in garbled {
            let enScore = analyzer.score(text: word, language: .english)
            // Should be low — garbled text doesn't match EN bigrams
            XCTAssertLessThan(enScore, 5.0, "Garbled text '\(word)' should have low EN score")
        }
    }

    func testConvertedFromGarbledHasHighUkrainianScore() {
        let analyzer = NGramAnalyzer.shared
        // "ghbdsn" on QWERTY = "привіт" on Ukrainian layout
        let converted = TextConverter.shared.convert("ghbdsn", from: .english, to: .ukrainian)
        XCTAssertEqual(converted, "привіт")
        let ukScore = analyzer.score(text: converted, language: .ukrainian)
        let enScore = analyzer.score(text: converted, language: .english)
        XCTAssertGreaterThan(ukScore, enScore, "Converted Ukrainian text should score higher in UK")
    }

    // MARK: - LayoutDetector: shouldSwitch

    func testShouldSwitchGarbledUkrainianToUkrainian() {
        let detector = LayoutDetector.shared
        let garbled = "ghbdsn"  // "привіт" typed on EN layout
        let converted = TextConverter.shared.convert(garbled, from: .english, to: .ukrainian)
        // The converted Ukrainian word should score higher → trigger switch
        let shouldSwitch = detector.shouldSwitch(word: converted, from: .english, to: .ukrainian)
        XCTAssertTrue(shouldSwitch, "Should suggest switching to Ukrainian for converted '\(converted)'")
    }

    func testShouldNotSwitchForValidEnglishWord() {
        let detector = LayoutDetector.shared
        // "the" is in EN dictionary and has strong EN n-gram score
        let shouldSwitch = detector.shouldSwitch(word: "the", from: .english, to: .ukrainian)
        XCTAssertFalse(shouldSwitch, "Should NOT switch for valid English word 'the'")
    }

    // MARK: - Accuracy benchmark (≥95% per PRD FR-03)

    func testAccuracyBenchmark() {
        // 50 EN / 50 UK test phrases — covers ≥ 3 char requirement
        let englishTexts = [
            "the", "and", "for", "are", "but", "not", "you", "all",
            "can", "her", "was", "one", "our", "out", "day", "get",
            "has", "him", "his", "how", "its", "may", "new", "now",
            "old", "see", "two", "who", "boy", "did", "its", "let",
            "put", "say", "she", "too", "use", "with", "from", "they",
            "this", "that", "have", "will", "your", "been", "good",
            "much", "some", "time"
        ]
        let ukrainianTexts = [
            "але", "або", "все", "для", "він", "вона", "вони", "нас",
            "так", "що", "той", "ця", "при", "від", "між", "після",
            "нові", "свої", "його", "цього", "такі", "хоча", "коли",
            "якщо", "тому", "тільки", "більше", "менше", "добре",
            "можна", "потрібно", "різних", "перший", "другий", "третій",
            "роботи", "людей", "країни", "потрібно", "дякую",
            "привіт", "розвиток", "виконати", "стати", "прийти",
            "народу", "школи", "місто", "право", "держава"
        ]

        let analyzer = NGramAnalyzer.shared
        var correct = 0
        var total = 0

        for text in englishTexts {
            if let result = analyzer.detectLanguage(of: text) {
                total += 1
                if result.language == .english { correct += 1 }
            }
        }

        for text in ukrainianTexts {
            if let result = analyzer.detectLanguage(of: text) {
                total += 1
                if result.language == .ukrainian { correct += 1 }
            }
        }

        let accuracy = total > 0 ? Double(correct) / Double(total) : 0.0
        print("N-gram accuracy: \(correct)/\(total) = \(String(format: "%.1f%%", accuracy * 100))")
        XCTAssertGreaterThanOrEqual(accuracy, 0.95, "N-gram accuracy must be ≥ 95% (FR-03)")
    }
}
