import Foundation

/// Manages the free tier limit: 5 strips per calendar day.
@Observable
final class FreeTierManager {

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let stripCountToday = "freeStripCountToday"
        static let stripDate = "freeStripDate"
    }

    static let dailyFreeLimit = 5

    private(set) var stripsUsedToday: Int = 0

    var stripsRemaining: Int {
        max(0, Self.dailyFreeLimit - stripsUsedToday)
    }

    var hasReachedLimit: Bool {
        stripsUsedToday >= Self.dailyFreeLimit
    }

    init() {
        refreshDayIfNeeded()
    }

    /// Call before allowing a strip. Returns true if the user can strip.
    func canStrip(isPro: Bool) -> Bool {
        if isPro { return true }
        refreshDayIfNeeded()
        return !hasReachedLimit
    }

    /// Record that N photos were stripped.
    func recordStrips(count: Int, isPro: Bool) {
        guard !isPro else { return }
        refreshDayIfNeeded()
        stripsUsedToday += count
        defaults.set(stripsUsedToday, forKey: Keys.stripCountToday)
    }

    // MARK: - Private

    private func refreshDayIfNeeded() {
        let today = Calendar.current.startOfDay(for: .now)

        if let savedDate = defaults.object(forKey: Keys.stripDate) as? Date {
            let savedDay = Calendar.current.startOfDay(for: savedDate)
            if today > savedDay {
                // New day — reset counter
                stripsUsedToday = 0
                defaults.set(0, forKey: Keys.stripCountToday)
                defaults.set(today, forKey: Keys.stripDate)
            } else {
                stripsUsedToday = defaults.integer(forKey: Keys.stripCountToday)
            }
        } else {
            // First launch
            defaults.set(today, forKey: Keys.stripDate)
            stripsUsedToday = 0
        }
    }
}
