import Foundation

/// Lightweight on-device analytics that tracks the conversion funnel:
/// install → onboarding → preview → strip → paywall_shown → purchase
///
/// All data stays on-device in UserDefaults. No networking.
/// Access stats via `AnalyticsLogger.shared.funnelReport()` in debug builds
/// or export via the Settings screen for your own analysis.
@Observable
final class AnalyticsLogger {

    static let shared = AnalyticsLogger()

    // MARK: - Event Types

    enum Event: String, CaseIterable, Codable {
        // Funnel stages (ordered)
        case appLaunch = "app_launch"
        case onboardingStarted = "onboarding_started"
        case onboardingCompleted = "onboarding_completed"
        case onboardingSkipped = "onboarding_skipped"
        case photosSelected = "photos_selected"
        case exposurePreviewViewed = "exposure_preview_viewed"
        case stripInitiated = "strip_initiated"
        case stripCompleted = "strip_completed"
        case photosSaved = "photos_saved"
        case photosShared = "photos_shared"
        case paywallShown = "paywall_shown"
        case paywallDismissed = "paywall_dismissed"
        case purchaseInitiated = "purchase_initiated"
        case purchaseCompleted = "purchase_completed"
        case purchaseCancelled = "purchase_cancelled"
        case purchaseRestored = "purchase_restored"

        // Feature usage
        case shareExtensionUsed = "share_extension_used"
        case customStripUsed = "custom_strip_used"
        case batchStripUsed = "batch_strip_used"
        case privacyReportViewed = "privacy_report_viewed"

        // Engagement
        case freeLimitReached = "free_limit_reached"

        /// Human-readable funnel stage name.
        var funnelStage: String? {
            switch self {
            case .appLaunch: return "Launch"
            case .onboardingCompleted, .onboardingSkipped: return "Onboarding"
            case .photosSelected: return "Photo Selection"
            case .exposurePreviewViewed: return "Exposure Preview"
            case .stripCompleted: return "Strip"
            case .paywallShown: return "Paywall"
            case .purchaseCompleted: return "Purchase"
            default: return nil
            }
        }
    }

    // MARK: - Stored Event

    struct LoggedEvent: Codable, Identifiable {
        let id: UUID
        let event: Event
        let timestamp: Date
        let metadata: [String: String]

        init(event: Event, metadata: [String: String] = [:]) {
            self.id = UUID()
            self.event = event
            self.timestamp = .now
            self.metadata = metadata
        }
    }

    // MARK: - Storage

    private let defaults = UserDefaults.standard
    private let eventsKey = "analytics_events"
    private let countsKey = "analytics_event_counts"
    private let installDateKey = "analytics_install_date"

    /// Rolling buffer of recent events (last 500). Older events are summarized into counts.
    private(set) var recentEvents: [LoggedEvent] = []

    /// Lifetime count per event type.
    private(set) var eventCounts: [String: Int] = [:]

    /// Install date for cohort tracking.
    private(set) var installDate: Date

    private let maxRecentEvents = 500

    // MARK: - Init

    private init() {
        // Set install date on first launch
        if let saved = defaults.object(forKey: installDateKey) as? Date {
            installDate = saved
        } else {
            installDate = .now
            defaults.set(installDate, forKey: installDateKey)
        }

        loadEvents()
        loadCounts()
    }

    // MARK: - Log Events

    /// Log an event with optional metadata.
    func log(_ event: Event, metadata: [String: String] = [:]) {
        let entry = LoggedEvent(event: event, metadata: metadata)

        recentEvents.append(entry)

        // Trim to buffer size
        if recentEvents.count > maxRecentEvents {
            recentEvents = Array(recentEvents.suffix(maxRecentEvents))
        }

        // Increment count
        let key = event.rawValue
        eventCounts[key, default: 0] += 1

        // Persist
        saveEvents()
        saveCounts()

        #if DEBUG
        let metaStr = metadata.isEmpty ? "" : " | \(metadata)"
        print("📊 [\(event.rawValue)]\(metaStr)")
        #endif
    }

    /// Convenience: log photo selection with count.
    func logPhotosSelected(count: Int) {
        log(.photosSelected, metadata: ["count": "\(count)"])
        if count > 1 {
            log(.batchStripUsed, metadata: ["count": "\(count)"])
        }
    }

    /// Convenience: log strip completion with stats.
    func logStripCompleted(photosCount: Int, fieldsRemoved: Int, hadGPS: Bool) {
        log(.stripCompleted, metadata: [
            "photos": "\(photosCount)",
            "fields_removed": "\(fieldsRemoved)",
            "had_gps": "\(hadGPS)"
        ])
    }

    // MARK: - Funnel Report

    /// Generate a conversion funnel report.
    /// Returns ordered stages with counts and conversion rates.
    func funnelReport() -> [(stage: String, count: Int, conversionRate: Double?)] {
        let stages: [(String, Event)] = [
            ("Launch", .appLaunch),
            ("Onboarding Done", .onboardingCompleted),
            ("Photos Selected", .photosSelected),
            ("Preview Viewed", .exposurePreviewViewed),
            ("Strip Completed", .stripCompleted),
            ("Paywall Shown", .paywallShown),
            ("Purchase Completed", .purchaseCompleted),
        ]

        var report: [(stage: String, count: Int, conversionRate: Double?)] = []
        var previousCount: Int?

        for (name, event) in stages {
            let count = eventCounts[event.rawValue, default: 0]
            let rate: Double? = previousCount.map { prev in
                prev > 0 ? Double(count) / Double(prev) * 100 : 0
            }
            report.append((stage: name, count: count, conversionRate: rate))
            previousCount = count
        }

        return report
    }

    /// Export all analytics data as JSON (for your own server/analysis).
    func exportJSON() -> Data? {
        let export: [String: Any] = [
            "install_date": ISO8601DateFormatter().string(from: installDate),
            "export_date": ISO8601DateFormatter().string(from: .now),
            "event_counts": eventCounts,
            "days_since_install": Calendar.current.dateComponents([.day], from: installDate, to: .now).day ?? 0,
            "recent_events_count": recentEvents.count,
        ]

        return try? JSONSerialization.data(withJSONObject: export, options: .prettyPrinted)
    }

    /// Plain-text funnel summary for debug/console.
    func funnelSummary() -> String {
        var lines = ["=== ExifArmor Conversion Funnel ==="]
        for entry in funnelReport() {
            let rateStr = entry.conversionRate.map { String(format: "(%.1f%%)", $0) } ?? ""
            lines.append("  \(entry.stage): \(entry.count) \(rateStr)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Persistence

    private func saveEvents() {
        if let data = try? JSONEncoder().encode(recentEvents) {
            defaults.set(data, forKey: eventsKey)
        }
    }

    private func loadEvents() {
        guard let data = defaults.data(forKey: eventsKey),
              let events = try? JSONDecoder().decode([LoggedEvent].self, from: data)
        else { return }
        recentEvents = events
    }

    private func saveCounts() {
        defaults.set(eventCounts, forKey: countsKey)
    }

    private func loadCounts() {
        if let counts = defaults.dictionary(forKey: countsKey) as? [String: Int] {
            eventCounts = counts
        }
    }

    /// Reset all analytics (for testing).
    func resetAll() {
        recentEvents = []
        eventCounts = [:]
        defaults.removeObject(forKey: eventsKey)
        defaults.removeObject(forKey: countsKey)
    }
}
