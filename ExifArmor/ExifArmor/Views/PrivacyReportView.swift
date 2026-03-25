import SwiftUI

struct PrivacyReportView: View {
    @Environment(PrivacyReportManager.self) private var report
    @Environment(StoreManager.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero stat
                    heroStat

                    // Stats grid
                    statsGrid

                    // Badges
                    badgesSection

                    // Streak
                    if report.currentStreak > 0 {
                        streakCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
            .background(Color("BackgroundDark"))
            .navigationTitle("Privacy Report")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .overlay {
                if report.totalPhotosStripped == 0 {
                    emptyState
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image("EmptyPrivacyReport")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("No photos protected yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color("TextPrimary"))

            Text("Strip metadata from your photos to start building your privacy report.")
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundDark"))
    }

    // MARK: - Hero

    private var heroStat: some View {
        VStack(spacing: 8) {
            Text("\(report.totalPhotosStripped)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("AccentCyan"), Color("AccentMagenta")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .contentTransition(.numericText())

            Text("Photos Protected")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            if report.daysProtecting > 0 {
                Text("Protecting your privacy for \(report.daysProtecting) day\(report.daysProtecting == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: 12) {
            reportCard(
                value: "\(report.totalFieldsRemoved)",
                label: "Fields Scrubbed",
                icon: "eye.slash.fill",
                color: Color("AccentCyan")
            )

            reportCard(
                value: "\(report.totalLocationStrips)",
                label: "Locations Hidden",
                icon: "location.slash.fill",
                color: Color("WarningRed")
            )
        }
    }

    private func reportCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title.weight(.bold).monospacedDigit())
                .foregroundStyle(Color("TextPrimary"))
                .contentTransition(.numericText())

            Text(label)
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Badges

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("TextPrimary"))
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: 16) {
                badgeItem("BadgeFirstStrip", "First Strip",
                          earned: report.hasEarnedFirstStrip)
                badgeItem("Badge100Photos", "Centurion",
                          earned: report.hasEarned100Badge)
                badgeItem("Badge1000Photos", "Sentinel",
                          earned: report.hasEarned1000Badge)
                badgeItem("BadgePro", "Pro User",
                          earned: store.isPro)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func badgeItem(_ imageName: String, _ label: String, earned: Bool) -> some View {
        VStack(spacing: 6) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .opacity(earned ? 1.0 : 0.25)
                .grayscale(earned ? 0 : 1)

            Text(label)
                .font(.caption2)
                .foregroundStyle(earned ? Color("TextPrimary") : Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Streak

    private var streakCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundStyle(Color("AccentGold"))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(report.currentStreak)-day streak")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("TextPrimary"))

                Text("You've protected photos \(report.currentStreak) day\(report.currentStreak == 1 ? "" : "s") in a row")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()
        }
        .padding(16)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
