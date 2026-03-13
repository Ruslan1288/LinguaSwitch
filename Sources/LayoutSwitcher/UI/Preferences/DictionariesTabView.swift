import SwiftUI

struct DictionariesTabView: View {
    @State private var enCount: Int = 0
    @State private var ukCount: Int = 0
    @State private var isRebuilding = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L("dict.title"))
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("dict.english")).font(.subheadline).foregroundColor(.secondary)
                    Text("\(enCount) words")
                        .font(.system(.body, design: .monospaced))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(L("dict.ukrainian")).font(.subheadline).foregroundColor(.secondary)
                    Text("\(ukCount) words")
                        .font(.system(.body, design: .monospaced))
                }
                Spacer()
            }
            .padding()
            .background(Color.secondary.opacity(0.08))
            .cornerRadius(8)

            Divider()

            Text(L("dict.bundled_note"))
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                rebuild()
            } label: {
                if isRebuilding {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text(L("dict.rebuilding"))
                    }
                } else {
                    Label(L("dict.rebuild"), systemImage: "arrow.clockwise")
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
