import SwiftUI

struct SoundsTabView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var soundManager = SoundManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PageTitle(title: "Sounds")

                SectionLabel(title: "Master")
                PrefsGroupBox {
                    PrefsToggleRow(
                        icon: "speaker.wave.3.fill", iconColor: .orange,
                        title: "Enable Sound Effects",
                        subtitle: "Audio feedback on layout changes",
                        isOn: $settings.soundEnabled
                    )
                }

                SectionLabel(title: "Events")
                PrefsGroupBox {
                    ForEach(Array(SoundEvent.allCases.enumerated()), id: \.element) { idx, event in
                        HStack(spacing: 12) {
                            Image(systemName: soundIcon(for: event))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(settings.soundEnabled ? .orange : .secondary)
                                .frame(width: DS.iconSize)
                            Toggle(event.displayName, isOn: Binding(
                                get: { soundManager.eventEnabled[event.rawValue] ?? true },
                                set: { soundManager.eventEnabled[event.rawValue] = $0 }
                            ))
                            .toggleStyle(.switch)
                            .disabled(!settings.soundEnabled)
                            Spacer()
                            Button {
                                soundManager.preview(event)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 10))
                                    Text("Preview")
                                        .font(.system(size: 12))
                                }
                                .foregroundColor(settings.soundEnabled ? .accentColor : .secondary)
                            }
                            .buttonStyle(.plain)
                            .disabled(!settings.soundEnabled)
                        }
                        .padding(.horizontal, DS.rowPadH)
                        .padding(.vertical, DS.rowPadV)
                        if idx < SoundEvent.allCases.count - 1 { InsetDivider() }
                    }
                }
                .opacity(settings.soundEnabled ? 1 : 0.5)

                Spacer(minLength: 20)
            }
            .padding(20)
        }
    }

    private func soundIcon(for event: SoundEvent) -> String {
        switch event.rawValue {
        case _ where event.rawValue.contains("auto"):   return "wand.and.stars"
        case _ where event.rawValue.contains("manual"): return "hand.tap.fill"
        default: return "speaker.wave.1.fill"
        }
    }
}
