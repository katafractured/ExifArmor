import SwiftUI

struct SettingsView: View {
    @Environment(StoreManager.self) private var store
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("defaultStripMode") private var defaultStripMode = "all"

    var body: some View {
        NavigationStack {
            List {
                // Pro status
                Section {
                    if store.isPro {
                        HStack(spacing: 12) {
                            Image("BadgePro")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("ExifArmor Pro")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Color("AccentCyan"))
                                Text("All features unlocked")
                                    .font(.caption)
                                    .foregroundStyle(Color("TextSecondary"))
                            }

                            Spacer()

                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Color("AccentCyan"))
                        }
                    } else {
                        NavigationLink {
                            ProUpgradeView()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Color("AccentGold"))
                                Text("Upgrade to Pro")
                                    .foregroundStyle(Color("TextPrimary"))
                            }
                        }

                        Button {
                            Task { await store.restorePurchases() }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(Color("AccentCyan"))
                                Text("Restore Purchase")
                            }
                        }
                    }
                }

                // Defaults
                Section {
                    Picker("Default Strip Mode", selection: $defaultStripMode) {
                        Text("Remove All").tag("all")
                        Text("Location Only").tag("location")
                        Text("Privacy Focused").tag("privacy")
                    }
                } header: {
                    Text("Defaults")
                } footer: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(defaultModeDescription)
                        Text("Remove All strips all detected metadata except image orientation.")
                        Text("Location Only removes GPS coordinates and altitude only.")
                        Text("Privacy Focused removes location, date/time, and device info, but keeps camera settings like lens, ISO, and exposure.")
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(Color("TextSecondary"))
                    }

                    Button {
                        hasCompletedOnboarding = false
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundStyle(Color("AccentCyan"))
                            Text("Replay Onboarding")
                        }
                    }

                    Link(destination: URL(string: "https://katafract.com/support/exifarmor")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(Color("AccentCyan"))
                            Text("Support")
                                .foregroundStyle(Color("TextPrimary"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }

                    Link(destination: URL(string: "https://katafract.com/privacy/exifarmor")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised")
                                .foregroundStyle(Color("AccentCyan"))
                            Text("Privacy Policy")
                                .foregroundStyle(Color("TextPrimary"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }

                    Link(destination: URL(string: "https://katafract.com/terms/exifarmor")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .foregroundStyle(Color("AccentCyan"))
                            Text("Terms of Use")
                                .foregroundStyle(Color("TextPrimary"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }
                }

                // Privacy
                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Privacy")
                                .font(.subheadline.weight(.semibold))
                            Text("ExifArmor never transmits your photos. All processing happens on your device.")
                                .font(.caption)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(Color("SuccessGreen"))
                    }
                }

                #if DEBUG
                Section("Developer") {
                    NavigationLink {
                        AnalyticsDebugView()
                    } label: {
                        Label("Analytics Debug", systemImage: "chart.bar.fill")
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var defaultModeDescription: String {
        switch defaultStripMode {
        case "location":
            return "Current default: Location Only. Best when you want to hide where a photo was taken but keep the rest of the camera metadata."
        case "privacy":
            return "Current default: Privacy Focused. Best when you want to remove personal identifiers but still keep photographic settings."
        default:
            return "Current default: Remove All. Best when you want the safest share-ready copy with the least metadata left behind."
        }
    }
}
