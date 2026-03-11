import SwiftUI
import AppKit

class DiaryPanel: NSPanel {
    static let shared = DiaryPanel()

    private init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
                   styleMask: [.titled, .closable, .resizable, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        title = "Diary"
        isReleasedWhenClosed = false
        contentView = NSHostingView(rootView: DiaryWindowView())
    }

    func show() {
        if !AppSettings.shared.diaryPassword.isEmpty {
            // Prompt for password
            let alert = NSAlert()
            alert.messageText = "Diary Password"
            alert.informativeText = "Enter password to open diary:"
            let field = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            alert.accessoryView = field
            alert.addButton(withTitle: "Open")
            alert.addButton(withTitle: "Cancel")
            if alert.runModal() == .alertFirstButtonReturn {
                if field.stringValue != AppSettings.shared.diaryPassword { return }
            } else { return }
        }
        center()
        orderFront(nil)
    }
}

struct DiaryWindowView: View {
    @State private var selectedDate = Date()
    @State private var search = ""
    @State private var entries: [DiaryEntry] = []

    var filtered: [DiaryEntry] {
        search.isEmpty ? entries : entries.filter { $0.text.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        HSplitView {
            VStack {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .onChange(of: selectedDate) { _ in loadEntries() }
                Spacer()
            }
            .frame(minWidth: 220, maxWidth: 260)

            VStack(spacing: 0) {
                HStack {
                    TextField("Search...", text: $search)
                        .textFieldStyle(.roundedBorder)
                    Button("Clear") { DiaryManager.shared.clearDate(selectedDate); loadEntries() }
                    Button("Export") { exportEntries() }
                }
                .padding(8)

                Divider()

                List(filtered, id: \.timestamp) { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(entry.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(entry.appName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(entry.text)
                            .font(.body)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(width: 700, height: 500)
        .onAppear { loadEntries() }
    }

    private func loadEntries() {
        entries = DiaryManager.shared.entriesForDate(selectedDate)
    }

    private func exportEntries() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "diary-export.txt"
        if panel.runModal() == .OK, let url = panel.url {
            let text = filtered.map { "[\($0.timestamp)] [\($0.appName)] \($0.text)" }.joined(separator: "\n")
            try? text.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
