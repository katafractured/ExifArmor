import SwiftUI

@main
struct ExifArmorApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var storeManager = StoreManager()
    @State private var privacyReport = PrivacyReportManager()
    @State private var freeTier = FreeTierManager()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environment(storeManager)
                    .environment(privacyReport)
                    .environment(freeTier)
                    .onAppear {
                        AnalyticsLogger.shared.log(.appLaunch)
                    }
            } else {
                OnboardingView(onComplete: {
                    AnalyticsLogger.shared.log(.onboardingCompleted)
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                })
                .onAppear {
                    AnalyticsLogger.shared.log(.onboardingStarted)
                }
            }
        }
    }
}
