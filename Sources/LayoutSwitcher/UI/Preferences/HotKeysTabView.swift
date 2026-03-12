import SwiftUI

struct HotKeysTabView: View {
    private let actions: [(String, String, [String])] = [
        ("arrow.left.arrow.right",   "Switch Layout",             ["⌥", "Space"]),
        ("character.cursor.ibeam",   "Convert Last Word",         ["⌥", "Z"]),
        ("selection.pin.in.out",     "Convert Selected Text",     ["⌥", "⇧", "Space"]),
        ("textformat.abc",           "Cycle Case",                ["⌥", "⇧", "C"]),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PageTitle(title: "Hot Keys")

                SectionLabel(title: "Default Shortcuts")
                PrefsGroupBox {
                    ForEach(Array(actions.enumerated()), id: \.offset) { idx, action in
                        HotKeyRow(icon: action.0, title: action.1, keys: action.2)
                        if idx < actions.count - 1 { InsetDivider() }
                    }
                }

                SectionLabel(title: "About")
                PrefsGroupBox {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.secondary)
                            .frame(width: DS.iconSize)
                        Text("Hotkeys are fixed in this version. Custom bindings coming soon.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, DS.rowPadH)
                    .padding(.vertical, DS.rowPadV)
                }

                Spacer(minLength: 20)
            }
            .padding(20)
        }
    }
}

private struct HotKeyRow: View {
    let icon: String
    let title: String
    let keys: [String]

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: DS.iconSize)
            Text(title)
                .font(.system(size: 13))
            Spacer()
            HStack(spacing: 3) {
                ForEach(keys, id: \.self) { key in
                    Text(key)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.primary.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5)
                                )
                        )
                }
            }
        }
        .padding(.horizontal, DS.rowPadH)
        .padding(.vertical, DS.rowPadV)
    }
}
