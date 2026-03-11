import SwiftUI

struct ExceptionsTabView: View {
    @ObservedObject var rulesManager = SwitchRulesManager.shared
    @ObservedObject var settings = AppSettings.shared
    @State private var newWord = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Word Exceptions")
                .font(.headline)
            Text("Words that will never be auto-switched.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                TextField("Add word...", text: $newWord)
                    .onSubmit { addWord() }
                Button("Add") { addWord() }
            }

            List {
                ForEach(rulesManager.exceptions, id: \.self) { word in
                    Text(word)
                }
                .onDelete { offsets in rulesManager.remove(at: offsets) }
            }
            .frame(height: 100)

            Divider().padding(.vertical, 8)

            Text("Excluded Apps")
                .font(.headline)
            Text("LayoutSwitcher is disabled in these apps.")
                .font(.caption)
                .foregroundColor(.secondary)

            List {
                ForEach(settings.excludedApps) { app in
                    HStack {
                        if let data = app.iconData, let img = NSImage(data: data) {
                            Image(nsImage: img).resizable().frame(width: 20, height: 20)
                        }
                        Text(app.name)
                        Spacer()
                        Text(app.bundleID).font(.caption).foregroundColor(.secondary)
                    }
                }
                .onDelete { offsets in
                    settings.excludedApps.remove(atOffsets: offsets)
                }
            }
            .frame(height: 100)

            Button("Add App...") { pickApp() }
        }
        .padding()
    }

    private func addWord() {
        guard !newWord.isEmpty else { return }
        rulesManager.add(newWord)
        newWord = ""
    }

    private func pickApp() {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            let bundle = Bundle(url: url)
            let bundleID = bundle?.bundleIdentifier ?? ""
            let name = bundle?.infoDictionary?["CFBundleDisplayName"] as? String
                    ?? bundle?.infoDictionary?["CFBundleName"] as? String
                    ?? url.deletingPathExtension().lastPathComponent
            let icon = NSWorkspace.shared.icon(forFile: url.path)
            let iconData = icon.tiffRepresentation
            let app = ExcludedApp(bundleID: bundleID, name: name, iconData: iconData)
            settings.excludedApps.append(app)
        }
    }
}
