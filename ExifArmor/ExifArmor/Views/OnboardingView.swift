import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0
    @AppStorage("defaultStripMode") private var defaultStripMode = "all"

    private let pages: [(image: String, title: String, subtitle: String)] = [
        (
            "OnboardingPhotosAreTalking",
            "Your Photos Are Talking",
            "Every photo you share contains hidden metadata — your GPS location, device model, and the exact time it was taken."
        ),
        (
            "OnboardingSeeWhatsExposed",
            "See What's Exposed",
            "ExifArmor reveals exactly what data is hiding in your photos, so you know the risk before you share."
        ),
        (
            "OnboardingOneTapProtect",
            "One Tap to Protect",
            "Strip metadata with a single tap. Your originals stay untouched — we create a clean copy that's safe to share."
        ),
    ]

    var body: some View {
        ZStack {
            Color("BackgroundDark").ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 32) {
                            Spacer()

                            Image(page.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 240, height: 240)
                                .padding(.top, 20)

                            VStack(spacing: 12) {
                                Text(page.title)
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Color("TextPrimary"))
                                    .multilineTextAlignment(.center)

                                Text(page.subtitle)
                                    .font(.body)
                                    .foregroundStyle(Color("TextSecondary"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }

                            if index == pages.count - 1 {
                                defaultModeChooser
                            }

                            Spacer()
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom controls
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color("AccentCyan") : Color("TextSecondary").opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentPage)
                        }
                    }

                    // Button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("AccentCyan"))
                            .foregroundStyle(Color("BackgroundDark"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)

                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            onComplete()
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color("TextSecondary"))
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var defaultModeChooser: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose your default strip mode")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color("TextPrimary"))

            Text("You can change this later in Settings. If you do nothing, ExifArmor defaults to Remove All.")
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))

            VStack(spacing: 10) {
                defaultModeButton(
                    title: "Remove All",
                    subtitle: "Best for the safest share-ready copy. Removes all detected metadata except orientation.",
                    mode: "all"
                )
                defaultModeButton(
                    title: "Location Only",
                    subtitle: "Removes GPS coordinates and altitude, but keeps the rest of the photo metadata.",
                    mode: "location"
                )
                defaultModeButton(
                    title: "Privacy Focused",
                    subtitle: "Removes location, date/time, and device info, but keeps camera settings like lens and exposure.",
                    mode: "privacy"
                )
            }
        }
        .padding(.horizontal, 24)
    }

    private func defaultModeButton(title: String, subtitle: String, mode: String) -> some View {
        Button {
            defaultStripMode = mode
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: defaultStripMode == mode ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(defaultStripMode == mode ? Color("AccentCyan") : Color("TextSecondary"))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("TextPrimary"))

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(14)
            .background(Color("CardBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        defaultStripMode == mode ? Color("AccentCyan").opacity(0.5) : Color("TextSecondary").opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
