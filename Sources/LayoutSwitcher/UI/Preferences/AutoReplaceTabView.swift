import SwiftUI

struct AutoReplaceTabView: View {
    @ObservedObject var manager = AutoReplaceManager.shared
    @State private var showAdd = false
    @State private var newAbbr = ""
    @State private var newRepl = ""

    var body: some View {
        VStack {
            List {
                ForEach(manager.entries) { entry in
                    HStack {
                        Text(entry.abbreviation)
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 100, alignment: .leading)
                        Text("→")
                            .foregroundColor(.secondary)
                        Text(entry.replacement)
                            .lineLimit(1)
                    }
                }
                .onDelete { manager.remove(at: $0) }
            }

            if showAdd {
                HStack {
                    TextField("Abbreviation", text: $newAbbr)
                        .frame(width: 120)
                    TextField("Replacement", text: $newRepl)
                    Button("Add") {
                        guard !newAbbr.isEmpty, !newRepl.isEmpty else { return }
                        manager.add(AutoReplaceEntry(abbreviation: newAbbr, replacement: newRepl))
                        newAbbr = ""; newRepl = ""; showAdd = false
                    }
                    Button("Cancel") { showAdd = false }
                }
                .padding(.horizontal)
            }

            HStack {
                Button("Add") { showAdd = true }
                Button("Export CSV") {
                    let panel = NSSavePanel()
                    panel.nameFieldStringValue = "autoreplace.csv"
                    if panel.runModal() == .OK, let url = panel.url {
                        try? manager.exportCSV().write(to: url, atomically: true, encoding: .utf8)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}
