import SwiftUI

// MARK: - Navigation sections

enum PrefsSection: String, CaseIterable, Identifiable {
    case general, hotkeys, exceptions, sounds, stats, dictionaries, about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:      return L("sidebar.general")
        case .hotkeys:      return L("sidebar.hotkeys")
        case .exceptions:   return L("sidebar.exceptions")
        case .sounds:       return L("sidebar.sounds")
        case .stats:        return L("sidebar.stats")
        case .dictionaries: return L("sidebar.dictionaries")
        case .about:        return L("sidebar.about")
        }
    }

    var icon: String {
        switch self {
        case .general:      return "gearshape.fill"
        case .hotkeys:      return "keyboard.fill"
        case .exceptions:   return "xmark.circle.fill"
        case .sounds:       return "speaker.wave.2.fill"
        case .stats:        return "chart.bar.fill"
        case .dictionaries: return "text.book.closed.fill"
        case .about:        return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .general:      return .gray
        case .hotkeys:      return Color(red: 0.4, green: 0.6, blue: 1.0)
        case .exceptions:   return .red
        case .sounds:       return .orange
        case .stats:        return Color(red: 0.2, green: 0.78, blue: 0.55)
        case .dictionaries: return Color(red: 0.6, green: 0.4, blue: 1.0)
        case .about:        return Color(red: 0.3, green: 0.6, blue: 1.0)
        }
    }
}

// MARK: - Main window

struct PreferencesWindow: View {
    @State private var selection: PrefsSection = .general

    var body: some View {
        HStack(spacing: 0) {
            // ── Sidebar ──────────────────────────────────
            VStack(spacing: 0) {
                // App header
                HStack(spacing: 8) {
                    Image(systemName: "keyboard.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.accentColor)
                    Text("LinguaSwitch")
                        .font(.system(size: 13, weight: .semibold))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 18)
                .padding(.bottom, 12)

                Divider()

                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(PrefsSection.allCases) { section in
                            SidebarNavButton(
                                icon: section.icon,
                                iconColor: section.color,
                                title: section.title,
                                isSelected: selection == section
                            ) {
                                selection = section
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
            }
            .frame(width: 182)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.6))

            Divider()

            // ── Content ──────────────────────────────────
            Group {
                switch selection {
                case .general:      GeneralTabView()
                case .hotkeys:      HotKeysTabView()
                case .exceptions:   ExceptionsTabView()
                case .sounds:       SoundsTabView()
                case .stats:        StatsTabView()
                case .dictionaries: DictionariesTabView()
                case .about:        AboutTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 700, height: 500)
    }
}

// MARK: - Sidebar nav button

private struct SidebarNavButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? iconColor : .secondary)
                    .frame(width: 18)
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(isSelected
                          ? Color.accentColor.opacity(0.14)
                          : (isHovered ? Color.primary.opacity(0.05) : .clear))
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
