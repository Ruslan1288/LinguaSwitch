import Foundation

class TextConverter {
    static let shared = TextConverter()

    // QWERTY → Ukrainian
    private let enToUk: [Character: Character] = [
        "q": "й", "w": "ц", "e": "у", "r": "к", "t": "е",
        "y": "н", "u": "г", "i": "ш", "o": "щ", "p": "з",
        "[": "х", "]": "ї", "a": "ф", "s": "і", "d": "в",
        "f": "а", "g": "п", "h": "р", "j": "о", "k": "л",
        "l": "д", ";": "ж", "'": "є", "z": "я", "x": "ч",
        "c": "с", "v": "м", "b": "и", "n": "т", "m": "ь",
        ",": "б", ".": "ю", "`": "ґ"
    ]

    private lazy var ukToEn: [Character: Character] = Dictionary(uniqueKeysWithValues: enToUk.map { ($1, $0) })

    func convert(_ text: String, from source: Language, to target: Language) -> String {
        switch (source, target) {
        case (.english, .ukrainian): return map(text, using: enToUk)
        case (.ukrainian, .english): return map(text, using: ukToEn)
        default: return text
        }
    }

    private func map(_ text: String, using table: [Character: Character]) -> String {
        String(text.map { char in
            let lower = Character(char.lowercased())
            if let mapped = table[lower] {
                return char.isUppercase ? Character(mapped.uppercased()) : mapped
            }
            return char
        })
    }

    // Transliterate Cyrillic → Latin
    func transliterate(_ text: String) -> String {
        let table: [Character: String] = [
            "а": "a", "б": "b", "в": "v", "г": "h", "ґ": "g",
            "д": "d", "е": "e", "є": "ye", "ж": "zh", "з": "z",
            "и": "y", "і": "i", "ї": "yi", "й": "y", "к": "k",
            "л": "l", "м": "m", "н": "n", "о": "o", "п": "p",
            "р": "r", "с": "s", "т": "t", "у": "u", "ф": "f",
            "х": "kh", "ц": "ts", "ч": "ch", "ш": "sh", "щ": "shch",
            "ь": "", "ю": "yu", "я": "ya",
            "ё": "yo", "ъ": "", "ы": "y", "э": "e"
        ]
        return text.map { char in
            let lower = Character(char.lowercased())
            if let t = table[lower] {
                return char.isUppercase ? t.capitalized : t
            }
            return String(char)
        }.joined()
    }

    // Number to Ukrainian text
    func numberToText(_ number: Int, language: Language) -> String {
        guard number >= 0 else { return "мінус " + numberToText(-number, language: language) }
        if number == 0 { return language == .english ? "zero" : "нуль" }

        switch language {
        case .ukrainian: return numberToUkrainian(number)
        case .english: return numberToEnglish(number)
        }
    }

    private func numberToUkrainian(_ n: Int) -> String {
        if n == 0 { return "нуль" }
        var result = ""
        var num = n

        let billions = ["", "мільярд", "мільярди", "мільярдів"]
        let millions = ["", "мільйон", "мільйони", "мільйонів"]
        let thousands = ["", "тисяча", "тисячі", "тисяч"]

        func form(_ n: Int, _ forms: [String]) -> String {
            let n10 = n % 10, n100 = n % 100
            if n100 >= 11 && n100 <= 19 { return forms[3] }
            if n10 == 1 { return forms[1] }
            if n10 >= 2 && n10 <= 4 { return forms[2] }
            return forms[3]
        }

        func hundreds(_ n: Int) -> String {
            let h = ["", "сто", "двісті", "триста", "чотириста",
                     "п'ятсот", "шістсот", "семисот", "восьмисот", "дев'ятсот"]
            return h[n]
        }

        func tens(_ n: Int) -> String {
            let t = ["", "", "двадцять", "тридцять", "сорок",
                     "п'ятдесят", "шістдесят", "сімдесят", "вісімдесят", "дев'яносто"]
            return t[n]
        }

        func ones(_ n: Int, feminine: Bool = false) -> String {
            let o = ["", feminine ? "одна" : "один", feminine ? "дві" : "два",
                     "три", "чотири", "п'ять", "шість", "сім", "вісім", "дев'ять"]
            let teen = ["десять", "одинадцять", "дванадцять", "тринадцять", "чотирнадцять",
                        "п'ятнадцять", "шістнадцять", "сімнадцять", "вісімнадцять", "дев'ятнадцять"]
            if n >= 10 && n <= 19 { return teen[n - 10] }
            return o[n]
        }

        func chunk(_ n: Int, feminine: Bool = false) -> String {
            var parts: [String] = []
            if n / 100 > 0 { parts.append(hundreds(n / 100)) }
            let rem = n % 100
            if rem >= 10 && rem <= 19 {
                parts.append(ones(rem))
            } else {
                if rem / 10 > 0 { parts.append(tens(rem / 10)) }
                if rem % 10 > 0 { parts.append(ones(rem % 10, feminine: feminine)) }
            }
            return parts.joined(separator: " ")
        }

        if num >= 1_000_000_000 {
            let b = num / 1_000_000_000
            result += chunk(b) + " " + form(b, billions)
            num %= 1_000_000_000
            if num > 0 { result += " " }
        }
        if num >= 1_000_000 {
            let m = num / 1_000_000
            result += chunk(m) + " " + form(m, millions)
            num %= 1_000_000
            if num > 0 { result += " " }
        }
        if num >= 1_000 {
            let t = num / 1_000
            result += chunk(t, feminine: true) + " " + form(t, thousands)
            num %= 1_000
            if num > 0 { result += " " }
        }
        if num > 0 {
            result += chunk(num)
        }

        return result.trimmingCharacters(in: .whitespaces)
    }

    private func numberToEnglish(_ n: Int) -> String {
        if n == 0 { return "zero" }
        let ones = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
                    "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
                    "seventeen", "eighteen", "nineteen"]
        let tens = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]

        func convert(_ n: Int) -> String {
            if n < 20 { return ones[n] }
            if n < 100 {
                let t = tens[n / 10]
                let o = n % 10 > 0 ? "-\(ones[n % 10])" : ""
                return t + o
            }
            let h = "\(ones[n / 100]) hundred"
            let rem = n % 100
            return rem > 0 ? "\(h) \(convert(rem))" : h
        }

        var result = ""
        var num = n
        if num >= 1_000_000_000 {
            result += "\(convert(num / 1_000_000_000)) billion "
            num %= 1_000_000_000
        }
        if num >= 1_000_000 {
            result += "\(convert(num / 1_000_000)) million "
            num %= 1_000_000
        }
        if num >= 1_000 {
            result += "\(convert(num / 1_000)) thousand "
            num %= 1_000
        }
        if num > 0 { result += convert(num) }
        return result.trimmingCharacters(in: .whitespaces)
    }
}
