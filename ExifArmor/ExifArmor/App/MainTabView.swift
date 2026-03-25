import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Strip", systemImage: "eye.slash.fill")
                }
                .tag(0)

            PrivacyReportView()
                .tabItem {
                    Label("Report", systemImage: "shield.checkered")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(Color("AccentCyan"))
    }
}
