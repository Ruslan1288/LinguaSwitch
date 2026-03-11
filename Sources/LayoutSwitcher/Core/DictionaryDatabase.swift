import Foundation
import GRDB

/// Manages the SQLite dictionary database.
/// Schema:
///   words(id, language TEXT, word TEXT, frequency REAL)  — indexed on (language, word)
///   ngrams(id, language TEXT, ngram TEXT, type TEXT, frequency REAL) — indexed on (language, ngram, type)
class DictionaryDatabase {
    static let shared = DictionaryDatabase()

    private var dbQueue: DatabaseQueue?
    private let dbURL: URL

    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let dir = appSupport.appendingPathComponent("LinguaSwitch")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        dbURL = dir.appendingPathComponent("dictionary.sqlite")
        setup()
    }

    // MARK: - Setup

    private func setup() {
        do {
            let queue = try DatabaseQueue(path: dbURL.path)
            try queue.write { db in
                // words table
                try db.execute(sql: """
                    CREATE TABLE IF NOT EXISTS words (
                        id        INTEGER PRIMARY KEY AUTOINCREMENT,
                        language  TEXT NOT NULL,
                        word      TEXT NOT NULL,
                        frequency REAL NOT NULL DEFAULT 1.0
                    );
                    CREATE UNIQUE INDEX IF NOT EXISTS idx_words ON words(language, word);
                """)

                // Add frequency column if upgrading from old schema
                let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(words)")
                let hasFrequency = columns.contains { ($0["name"] as? String) == "frequency" }
                if !hasFrequency {
                    try db.execute(sql: "ALTER TABLE words ADD COLUMN frequency REAL NOT NULL DEFAULT 1.0")
                }

                // ngrams table
                try db.execute(sql: """
                    CREATE TABLE IF NOT EXISTS ngrams (
                        id        INTEGER PRIMARY KEY AUTOINCREMENT,
                        language  TEXT NOT NULL,
                        ngram     TEXT NOT NULL,
                        type      TEXT NOT NULL,
                        frequency REAL NOT NULL DEFAULT 1.0
                    );
                    CREATE UNIQUE INDEX IF NOT EXISTS idx_ngrams ON ngrams(language, ngram, type);
                """)
            }
            dbQueue = queue

            // Seed from bundled .txt files if DB is empty
            let wordCount = try queue.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM words") ?? 0
            }
            if wordCount == 0 {
                seedWords()
            }

            // Seed ngrams if empty
            let ngramCount = try queue.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM ngrams") ?? 0
            }
            if ngramCount == 0 {
                seedNgrams()
            }
        } catch {
            print("DictionaryDatabase setup error: \(error)")
        }
    }

    // MARK: - Seeding Words

    private func seedWords() {
        guard let queue = dbQueue else { return }
        let pairs: [(resource: String, language: String)] = [
            ("en_words", "en"),
            ("uk_words", "uk")
        ]
        do {
            for (resource, lang) in pairs {
                guard let url = Bundle.module.url(forResource: resource, withExtension: "txt"),
                      let content = try? String(contentsOf: url, encoding: .utf8) else { continue }
                let words = content.components(separatedBy: .newlines)
                    .map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty && $0.count >= 2 }

                // Single transaction per language — fastest for bulk inserts
                try queue.write { db in
                    for word in words {
                        try db.execute(
                            sql: "INSERT OR IGNORE INTO words(language, word) VALUES (?, ?)",
                            arguments: [lang, word]
                        )
                    }
                }
                print("DictionaryDatabase: seeded \(words.count) \(lang) words")
            }
        } catch {
            print("DictionaryDatabase seed error: \(error)")
        }
    }

    // MARK: - Seeding N-grams

    private func seedNgrams() {
        guard let queue = dbQueue else { return }

        let enBigrams: [(String, Double)] = [
            ("th", 35.6), ("he", 30.7), ("in", 24.3), ("er", 20.5), ("an", 19.9),
            ("re", 18.5), ("on", 17.6), ("en", 17.5), ("at", 14.9), ("es", 14.5),
            ("ed", 14.3), ("te", 13.5), ("ti", 13.4), ("or", 12.8), ("it", 12.4),
            ("ng", 11.8), ("is", 11.3), ("al", 10.9), ("ar", 10.7), ("st", 10.5),
            ("to", 10.4), ("nt", 10.4), ("ha", 9.3),  ("nd", 9.3),  ("ou", 8.7),
            ("ea", 8.7),  ("hi", 8.7),  ("le", 8.3),  ("se", 8.3),  ("of", 7.6),
            ("ve", 7.2),  ("co", 7.1),  ("me", 7.1),  ("de", 6.9),  ("ro", 6.7),
            ("li", 6.6),  ("ri", 6.5),  ("io", 6.4),  ("ss", 6.1),  ("si", 6.0)
        ]
        let ukBigrams: [(String, Double)] = [
            ("ст", 18.5), ("пр", 20.0), ("на", 18.0), ("ні", 17.5), ("та", 16.5),
            ("ко", 16.0), ("ро", 15.5), ("ти", 15.0), ("ри", 14.5), ("ор", 14.0),
            ("ен", 13.0), ("не", 12.5), ("ос", 12.0), ("ар", 11.5), ("ра", 11.0),
            ("за", 10.5), ("ан", 10.0), ("ій", 9.0),  ("ви", 8.5),  ("по", 8.0),
            ("го", 7.5),  ("де", 7.0),  ("ли", 7.0),  ("те", 6.5),  ("ди", 6.0),
            ("ло", 5.5),  ("ть", 5.5),  ("во", 5.0),  ("ле", 5.0),  ("ми", 4.8),
            ("кр", 4.5),  ("тр", 4.0),  ("до", 4.0),  ("ла", 3.8),  ("со", 3.7),
            ("ін", 3.5),  ("що", 13.5), ("ою", 9.5),  ("но", 8.0),  ("ва", 7.2)
        ]
        let enTrigrams: [(String, Double)] = [
            ("the", 35.1), ("and", 15.9), ("ing", 11.5), ("ion", 8.3), ("tio", 7.7),
            ("ent", 7.0),  ("ati", 6.5),  ("for", 6.3),  ("her", 6.0), ("ter", 5.9),
            ("hat", 5.7),  ("tha", 5.5),  ("ere", 5.4),  ("con", 5.2), ("ons", 5.1),
            ("est", 5.0),  ("all", 4.8),  ("int", 4.8),  ("ith", 4.7), ("rea", 4.6),
            ("ate", 4.5),  ("his", 4.4),  ("not", 4.3),  ("res", 4.2), ("ver", 4.1)
        ]
        let ukTrigrams: [(String, Double)] = [
            ("про", 15.0), ("ств", 13.0), ("ого", 12.5), ("ати", 11.5), ("при", 9.5),
            ("ний", 10.5), ("нні", 10.0), ("від", 8.0),  ("між", 7.5),  ("час", 7.0),
            ("ції", 6.5),  ("пра", 5.5),  ("ста", 5.3),  ("вно", 5.0),  ("яко", 4.8),
            ("для", 4.5),  ("але", 4.3),  ("тіл", 4.0),  ("нас", 3.8),  ("має", 3.5),
            ("або", 4.2),  ("все", 3.9),  ("так", 4.1),  ("які", 8.5),  ("ден", 5.8)
        ]

        do {
            try queue.write { db in
                for (ngram, freq) in enBigrams {
                    try db.execute(
                        sql: "INSERT OR IGNORE INTO ngrams(language, ngram, type, frequency) VALUES (?, ?, ?, ?)",
                        arguments: ["en", ngram, "bigram", freq]
                    )
                }
                for (ngram, freq) in ukBigrams {
                    try db.execute(
                        sql: "INSERT OR IGNORE INTO ngrams(language, ngram, type, frequency) VALUES (?, ?, ?, ?)",
                        arguments: ["uk", ngram, "bigram", freq]
                    )
                }
                for (ngram, freq) in enTrigrams {
                    try db.execute(
                        sql: "INSERT OR IGNORE INTO ngrams(language, ngram, type, frequency) VALUES (?, ?, ?, ?)",
                        arguments: ["en", ngram, "trigram", freq]
                    )
                }
                for (ngram, freq) in ukTrigrams {
                    try db.execute(
                        sql: "INSERT OR IGNORE INTO ngrams(language, ngram, type, frequency) VALUES (?, ?, ?, ?)",
                        arguments: ["uk", ngram, "trigram", freq]
                    )
                }
            }
            print("DictionaryDatabase: seeded ngrams")
        } catch {
            print("DictionaryDatabase ngram seed error: \(error)")
        }
    }

    /// Clears and re-seeds all words from bundled .txt files.
    func rebuildFromBundles() {
        guard let queue = dbQueue else { return }
        do {
            try queue.write { db in
                try db.execute(sql: "DELETE FROM words")
            }
            seedWords()
        } catch {
            print("DictionaryDatabase rebuild error: \(error)")
        }
    }

    // MARK: - Bulk Import

    /// Import words from a plain-text file (one word per line).
    func importWords(from url: URL, language: String) throws {
        guard let queue = dbQueue else { return }
        let content = try String(contentsOf: url, encoding: .utf8)
        let words = content.components(separatedBy: .newlines)
            .map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && $0.count >= 2 }
        try queue.write { db in
            for word in words {
                try db.execute(
                    sql: "INSERT OR IGNORE INTO words(language, word) VALUES (?, ?)",
                    arguments: [language, word]
                )
            }
        }
        print("Imported \(words.count) \(language) words")
    }

    // MARK: - Queries

    func contains(word: String, language: String) -> Bool {
        guard let queue = dbQueue else { return false }
        let lower = word.lowercased()
        let count = try? queue.read { db in
            try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM words WHERE language = ? AND word = ?",
                arguments: [language, lower]
            ) ?? 0
        }
        return (count ?? 0) > 0
    }

    func wordCount(language: String) -> Int {
        guard let queue = dbQueue else { return 0 }
        return (try? queue.read { db in
            try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM words WHERE language = ?",
                arguments: [language]
            ) ?? 0
        }) ?? 0
    }

    func ngramFrequency(ngram: String, type: String, language: String) -> Double? {
        guard let queue = dbQueue else { return nil }
        return try? queue.read { db in
            try Double.fetchOne(
                db,
                sql: "SELECT frequency FROM ngrams WHERE language = ? AND ngram = ? AND type = ?",
                arguments: [language, ngram, type]
            )
        }
    }
}
