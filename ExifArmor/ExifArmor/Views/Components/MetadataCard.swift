import SwiftUI

enum MetadataSeverity {
    case critical, warning, info

    var borderOpacity: Double {
        switch self {
        case .critical: return 0.4
        case .warning: return 0.25
        case .info: return 0.15
        }
    }
}

/// A card that displays a category of metadata with an icon and severity indicator.
struct MetadataCard<Content: View>: View {
    let icon: String
    let title: String
    let iconColor: Color
    let severity: MetadataSeverity
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 28, height: 28)
                    .background(iconColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("TextPrimary"))
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                if severity == .critical {
                    Text("HIGH RISK")
                        .font(.caption2.bold())
                        .foregroundStyle(iconColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(iconColor.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            content
        }
        .padding(16)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(iconColor.opacity(severity.borderOpacity), lineWidth: 1)
        )
    }
}

/// A single label:value row inside a metadata card.
struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))
                .frame(width: 80, alignment: .leading)

            Text(value)
                .font(.caption.monospaced())
                .foregroundStyle(Color("TextPrimary"))
                .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 2)
    }
}
