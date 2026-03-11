import SwiftUI

struct StatsTabView: View {
    @State private var autoCount   = 0
    @State private var manualCount = 0
    @State private var topApps: [AppStat] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 24) {
                StatCard(title: "Auto Switches",   value: autoCount,                color: .blue)
                StatCard(title: "Manual Switches", value: manualCount,              color: .green)
                StatCard(title: "Total",           value: autoCount + manualCount,  color: .secondary)
            }

            Divider()

            Text("Top Apps")
                .font(.headline)

            if topApps.isEmpty {
                Text("No data yet — start typing!")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            } else {
                ForEach(topApps) { app in
                    HStack {
                        Text(app.name)
                        Spacer()
                        Text("\(app.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            HStack {
                Spacer()
                Button("Reset Stats") {
                    StatsManager.shared.reset()
                    refresh()
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear { refresh() }
    }

    private func refresh() {
        autoCount   = StatsManager.shared.autoSwitchCount
        manualCount = StatsManager.shared.manualSwitchCount
        topApps     = StatsManager.shared.topApps()
    }
}

struct AppStat: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
}

private struct StatCard: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}
