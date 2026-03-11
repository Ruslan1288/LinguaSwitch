import SwiftUI

struct AboutTabView: View {
    private let version = "0.5.0"
    private let buildDate = "March 2026"

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "keyboard")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(.accentColor)

            VStack(spacing: 4) {
                Text("LinguaSwitch")
                    .font(.title2.bold())
                Text("Version \(version) · \(buildDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider().frame(width: 240)

            VStack(spacing: 6) {
                infoRow(label: "Auto-switch", value: "EN ↔ UA layout detection")
                infoRow(label: "Engine", value: "N-gram + Dictionary (SQLite)")
                infoRow(label: "Platform", value: "macOS 13+")
            }
            .font(.callout)

            Spacer()

            Text("Built with Swift & SwiftUI")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .trailing)
            Text(value)
                .fontWeight(.medium)
        }
    }
}
