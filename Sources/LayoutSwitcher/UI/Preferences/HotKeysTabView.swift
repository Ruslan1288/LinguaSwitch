import SwiftUI

struct HotKeysTabView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Default Hotkeys")
                .font(.headline)
                .padding(.bottom, 4)
            HStack {
                Text("Switch Layout:")
                Spacer()
                Text("⌥Space")
                    .font(.system(.body, design: .monospaced))
                    .padding(4)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(4)
            }
            HStack {
                Text("Switch Selected Text Layout:")
                Spacer()
                Text("⌥⇧Space")
                    .font(.system(.body, design: .monospaced))
                    .padding(4)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(4)
            }
            HStack {
                Text("Convert Last Word:")
                Spacer()
                Text("⌥Z")
                    .font(.system(.body, design: .monospaced))
                    .padding(4)
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(4)
            }
            Divider().padding(.vertical, 8)
            Text("All Actions")
                .font(.headline)
            List(HotKeyAction.allCases, id: \.self) { action in
                HStack {
                    Text(action.displayName)
                    Spacer()
                    Text("—")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
