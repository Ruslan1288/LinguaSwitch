import SwiftUI

struct DictionariesTabView: View {
    @State private var enCount: Int = 0
    @State private var ukCount: Int = 0
    @State private var isRebuilding = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dictionaries")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("English").font(.subheadline).foregroundColor(.secondary)
                    Text("\(enCount) words")
                        .font(.system(.body, design: .monospaced))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ukrainian").font(.subheadline).foregroundColor(.secondary)
                    Text("\(ukCount) words")
                        .font(.system(.body, design: .monospaced))
                }
                Spacer()
            }
            .padding()
            .background(Color.secondary.opacity(0.08))
            .cornerRadius(8)

            Divider()

            Text("The dictionary is bundled with the app and loaded into SQLite on first launch.")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                rebuild()
            } label: {
                if isRebuilding {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Rebuilding…")
                    }
                } else {
                    Label("Rebuild Dictionary", systemImage: "arrow.clockwise")
                }
            }
            .disabled(isRebuilding)

            Spacer()
        }
        .padding()
        .onAppear { loadCounts() }
    }

    private func loadCounts() {
        DispatchQueue.global(qos: .userInitiated).async {
            let en = DictionaryDatabase.shared.wordCount(language: "en")
            let uk = DictionaryDatabase.shared.wordCount(language: "uk")
            DispatchQueue.main.async {
                enCount = en
                ukCount = uk
            }
        }
    }

    private func rebuild() {
        isRebuilding = true
        DispatchQueue.global(qos: .userInitiated).async {
            DictionaryDatabase.shared.rebuildFromBundles()
            let en = DictionaryDatabase.shared.wordCount(language: "en")
            let uk = DictionaryDatabase.shared.wordCount(language: "uk")
            DispatchQueue.main.async {
                enCount = en
                ukCount = uk
                isRebuilding = false
            }
        }
    }
}
