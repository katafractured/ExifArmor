import SwiftUI

struct StripResultView: View {
    let viewModel: PhotoStripViewModel
    let onSave: () -> Void
    let onShare: () -> Void
    let onDone: () -> Void

    @State private var showBeforeAfter = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Success header
                successHeader

                // Stats summary
                statsSummary

                metadataOutcomeSummary

                // Cleaned photos grid
                cleanedPhotosGrid

                // Action buttons
                actionButtons
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(Color("BackgroundDark"))
    }

    // MARK: - Success Header

    private var successHeader: some View {
        VStack(spacing: 12) {
            Image("EmptyAllClean")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            Text("Photos Cleaned!")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("TextPrimary"))

            Text("All selected metadata has been removed.")
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
        }
    }

    // MARK: - Stats

    private var statsSummary: some View {
        HStack(spacing: 0) {
            statItem(
                value: "\(viewModel.stripResults.count)",
                label: "Photos",
                icon: "photo.fill"
            )

            Divider()
                .frame(height: 40)
                .background(Color("TextSecondary").opacity(0.3))

            statItem(
                value: "\(viewModel.totalFieldsRemoved)",
                label: "Fields Removed",
                icon: "eye.slash.fill"
            )

            if viewModel.hadLocationData {
                Divider()
                    .frame(height: 40)
                    .background(Color("TextSecondary").opacity(0.3))

                statItem(
                    value: "✓",
                    label: "GPS Stripped",
                    icon: "location.slash.fill"
                )
            }
        }
        .padding(.vertical, 16)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var metadataOutcomeSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What Changed")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            outcomeSection(
                title: "Removed",
                items: removedMetadataItems,
                tint: Color("WarningRed")
            )

            outcomeSection(
                title: "Kept",
                items: keptMetadataItems,
                tint: Color("SuccessGreen")
            )
        }
        .padding(16)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func outcomeSection(title: String, items: [String], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)

            FlowLayout(items: items, tint: tint)
        }
    }

    private var removedMetadataItems: [String] {
        var items: [String] = []
        let options = viewModel.stripOptions

        if options.removeAll || options.removeLocation {
            items.append("GPS location")
            items.append("Altitude")
        }
        if options.removeAll || options.removeDateTime {
            items.append("Date & time")
        }
        if options.removeAll || options.removeDeviceInfo {
            items.append("Device info")
        }
        if options.removeAll || options.removeCameraSettings {
            items.append("Camera settings")
        }

        return items
    }

    private var keptMetadataItems: [String] {
        let options = viewModel.stripOptions
        var items: [String] = ["Image orientation"]

        if !options.removeAll && !options.removeLocation {
            items.append("GPS location")
        }
        if !options.removeAll && !options.removeDateTime {
            items.append("Date & time")
        }
        if !options.removeAll && !options.removeDeviceInfo {
            items.append("Device info")
        }
        if !options.removeAll && !options.removeCameraSettings {
            items.append("Camera settings")
        }

        return items
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(Color("AccentCyan"))

            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Grid

    private var cleanedPhotosGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8),
        ], spacing: 8) {
            ForEach(viewModel.stripResults) { result in
                Image(uiImage: result.cleanedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(minHeight: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.caption)
                            .foregroundStyle(Color("SuccessGreen"))
                            .padding(4)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(4)
                    }
            }
        }
    }

    // MARK: - Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onSave) {
                Label("Save to Photo Library", systemImage: "square.and.arrow.down.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("AccentCyan"))
                    .foregroundStyle(Color("BackgroundDark"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            HStack(spacing: 12) {
                Button(action: onShare) {
                    Label("Share Clean Copy", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("CardBackground"))
                        .foregroundStyle(Color("AccentCyan"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("AccentCyan").opacity(0.3), lineWidth: 1)
                        )
                }

                Button(action: onDone) {
                    Text("Done")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("CardBackground"))
                        .foregroundStyle(Color("TextSecondary"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

private struct FlowLayout: View {
    let items: [String]
    let tint: Color

    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(tint.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }
}
