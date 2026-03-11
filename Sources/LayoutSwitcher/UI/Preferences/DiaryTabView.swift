import SwiftUI

struct DiaryTabView: View {
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        Form {
            Section("Diary Settings") {
                Toggle("Enable Diary (Keylogger)", isOn: $settings.diaryEnabled)
                Toggle("Track Clipboard Copies", isOn: $settings.diaryTrackClipboard)
                    .disabled(!settings.diaryEnabled)
                HStack {
                    Text("Keep entries for")
                    Stepper("\(settings.diaryKeepDaysCount) days", value: $settings.diaryKeepDaysCount, in: 0...365)
                    if settings.diaryKeepDaysCount == 0 {
                        Text("(forever)").foregroundColor(.secondary)
                    }
                }
                .disabled(!settings.diaryEnabled)
                HStack {
                    Text("Password")
                    SecureField("Leave empty for no password", text: $settings.diaryPassword)
                }
                .disabled(!settings.diaryEnabled)
            }
            Section {
                Button("Open Diary Window") { DiaryPanel.shared.show() }
                    .disabled(!settings.diaryEnabled)
            }
        }
        .padding()
    }
}
