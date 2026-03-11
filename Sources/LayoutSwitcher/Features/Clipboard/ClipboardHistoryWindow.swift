import SwiftUI
import AppKit

class ClipboardHistoryPanel: NSPanel {
    static let shared = ClipboardHistoryPanel()

    private init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 400, height: 480),
                   styleMask: [.titled, .closable, .nonactivatingPanel, .utilityWindow],
                   backing: .buffered, defer: false)
        title = "Clipboard History"
        isReleasedWhenClosed = false
        level = .floating
        contentView = NSHostingView(rootView: ClipboardHistoryView())
    }

    func show() {
        center()
        orderFront(nil)
    }
}

struct ClipboardHistoryView: View {
    @ObservedObject var clipboard = ClipboardManager.shared
    @State private var search = ""

    var filtered: [String] {
        search.isEmpty ? clipboard.history : clipboard.history.filter { $0.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search...", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding(8)

            List(filtered, id: \.self) { item in
                Button(action: { paste(item) }) {
                    Text(item)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 400, height: 480)
    }

    private func paste(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        ClipboardHistoryPanel.shared.close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ClipboardManager.shared.pasteWithoutFormatting()
        }
    }
}
