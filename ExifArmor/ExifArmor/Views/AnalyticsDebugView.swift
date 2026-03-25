import SwiftUI

/// Debug-only view that shows the conversion funnel and event log.
/// Access from Settings → "Analytics Debug" (only visible in DEBUG builds).
struct AnalyticsDebugView: View {
    private let analytics = AnalyticsLogger.shared

    @State private var showExportSheet = false
    @State private var exportData: String = ""

    var body: some View {
        List {
            // Funnel
            Section("Conversion Funnel") {
                ForEach(analytics.funnelReport(), id: \.stage) { entry in
                    HStack {
                        Text(entry.stage)
                            .font(.subheadline)

                        Spacer()

                        Text("\(entry.count)")
                            .font(.subheadline.monospacedDigit().bold())
                            .foregroundStyle(Color("AccentCyan"))

                        if let rate = entry.conversionRate {
                            Text(String(format: "%.0f%%", rate))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(rate >= 50 ? Color("SuccessGreen") :
                                                    rate >= 20 ? Color("AccentGold") :
                                                    Color("WarningRed"))
                                .frame(width: 44, alignment: .trailing)
                        } else {
                            Text("—")
                                .font(.caption)
                                .foregroundStyle(Color("TextSecondary"))
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                }
            }

            // Counts
            Section("All Event Counts") {
                ForEach(analytics.eventCounts.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    HStack {
                        Text(key)
                            .font(.caption.monospaced())
                        Spacer()
                        Text("\(value)")
                            .font(.caption.monospacedDigit().bold())
                    }
                }
            }

            // Recent events
            Section("Recent Events (last \(analytics.recentEvents.count))") {
                ForEach(analytics.recentEvents.suffix(20).reversed()) { event in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(event.event.rawValue)
                                .font(.caption.monospaced().bold())
                            Spacer()
                            Text(event.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                        if !event.metadata.isEmpty {
                            Text(event.metadata.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))
                                .font(.caption2)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }
                }
            }

            // Actions
            Section {
                Button("Export JSON") {
                    if let data = analytics.exportJSON(),
                       let str = String(data: data, encoding: .utf8) {
                        exportData = str
                        showExportSheet = true
                    }
                }

                Button("Reset All Analytics", role: .destructive) {
                    analytics.resetAll()
                }
            }
        }
        .navigationTitle("Analytics Debug")
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(items: [exportData])
        }
    }
}
