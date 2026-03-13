import SwiftUI

struct ExceptionsTabView: View {
    @ObservedObject var rulesManager = SwitchRulesManager.shared
    @ObservedObject var settings = AppSettings.shared
    @State private var newWord = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PageTitle(title: L("exceptions.title"))

                SectionLabel(title: L("exceptions.word_exceptions"))
                Text(L("exceptions.word_exceptions_sub"))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)

                PrefsGroupBox {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: DS.iconSize)
                        TextField(L("exceptions.add_word_placeholder"), text: $newWord)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                            .onSubmit { addWord() }
                        if !newWord.isEmpty {
                            Button {
                                addWord()
                            } label: {
                                Text(L("exceptions.add"))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DS.rowPadH)
                    .padding(.vertical, DS.rowPadV)
                }

                if !rulesManager.exceptions.isEmpty {
                    PrefsGroupBox {
                        ForEach(Array(rulesManager.exceptions.enumerated()), id: \.element) { idx, word in
                            HStack(spacing: 12) {
                                Image(systemName: "text.word.spacing")
                                    .foregroundColor(.secondary)
                                    .frame(width: DS.iconSize)
                                Text(word)
                                    .font(.system(size: 13))
                                Spacer()
                                Button {
                                    rulesManager.remove(at: IndexSet(integer: idx))
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, DS.rowPadH)
                            .padding(.vertical, DS.rowPadV)
                            if idx < rulesManager.exceptions.count - 1 {
                                InsetDivider()
                            }
                        }
                    }
                    .padding(.top, 8)
                }

                SectionLabel(title: L("exceptions.excluded_apps"))
                Text(L("exceptions.excluded_apps_sub"))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)

                PrefsGroupBox {
                    if settings.excludedApps.isEmpty {
                        HStack(spacing: 12) {
                            Image(systemName: "app.dashed")
                                .foregroundColor(.secondary)
                                .frame(width: DS.iconSize)
                            Text(L("exceptions.no_excluded_apps"))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, DS.rowPadH)
                        .padding(.vertical, DS.rowPadV)
                    } else {
                        ForEach(Array(settings.excludedApps.enumerated()), id: \.element.id) { idx, app in
                            HStack(spacing: 12) {
                                if let data = app.iconData, let img = NSImage(data: data) {
                                    Image(nsImage: img)
                                        .resizable()
                                        .frame(width: DS.iconSize, height: DS.iconSize)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Image(systemName: "app.fill")
                                        .foregroundColor(.secondary)
                                        .frame(width: DS.iconSize)
                                }
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(app.name).font(.system(size: 13))
                                    Text(app.bundleID).font(.system(size: 11)).foregroundColor(.secondary)
                                }
                                Spacer()
                                Button {
                                    settings.excludedApps.remove(atOffsets: IndexSet(integer: idx))
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, DS.rowPadH)
                            .padding(.vertical, DS.rowPadV)
                            if idx < settings.excludedApps.count - 1 {
                                InsetDivider()
                            }
                        }
                    }
                }

                Button {
                    pickApp()
                } label: {
                    Label(L("exceptions.add_app"), systemImage: "plus")
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                .padding(.top, 10)

                Spacer(minLength: 20)
            }
            .padding(20)
        }
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
            let app = ExcludedApp(bundleID: bundleID, name: name, iconData: icon.tiffRepresentation)
            settings.excludedApps.append(app)
        }
    }
}
