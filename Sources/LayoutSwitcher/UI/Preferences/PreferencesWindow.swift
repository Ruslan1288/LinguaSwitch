import SwiftUI

struct PreferencesWindow: View {
    var body: some View {
        TabView {
            GeneralTabView()
                .tabItem { Label("General", systemImage: "gearshape") }
            HotKeysTabView()
                .tabItem { Label("Hot Keys", systemImage: "keyboard") }
            ExceptionsTabView()
                .tabItem { Label("Exceptions", systemImage: "list.dash") }
            SoundsTabView()
                .tabItem { Label("Sounds", systemImage: "speaker.wave.2") }
            StatsTabView()
                .tabItem { Label("Stats", systemImage: "chart.bar") }
            DictionariesTabView()
                .tabItem { Label("Dictionaries", systemImage: "text.book.closed") }
            AboutTabView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 560, height: 480)
    }
}
