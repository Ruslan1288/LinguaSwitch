import SwiftUI

struct SoundsTabView: View {
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var soundManager = SoundManager.shared

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Enable Sounds", isOn: $settings.soundEnabled)
                .font(.headline)
                .padding(.bottom, 8)

            Divider()

            List(SoundEvent.allCases, id: \.self) { event in
                HStack {
                    Toggle(event.displayName, isOn: Binding(
                        get: { soundManager.eventEnabled[event.rawValue] ?? true },
                        set: { soundManager.eventEnabled[event.rawValue] = $0 }
                    ))
                    Spacer()
                    Button("Preview") { soundManager.preview(event) }
                        .disabled(!settings.soundEnabled)
                }
            }
        }
        .padding()
    }
}
