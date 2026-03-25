import Foundation

/// Tracks lifetime privacy stats — shared with the share extension via App Group.
@Observable
final class PrivacyReportManager {

    // MARK: - App Group

    /// Change this to your actual App Group identifier after creating it in Xcode.
    static let appGroupID = "group.com.katafract.exifarmor"

    private let defaults = UserDefaults.standard

    // MARK: - Keys

    private enum Keys {
        static let totalStripped = "totalPhotosStripped"
        static let totalFieldsRemoved = "totalFieldsRemoved"
        static let totalLocationStrips = "totalLocationStrips"
        static let firstStripDate = "firstStripDate"
        static let streakLastDate = "streakLastDate"
        static let currentStreak = "currentStreak"
    }

    // MARK: - Published Properties

    private(set) var totalPhotosStripped: Int = 0
    private(set) var totalFieldsRemoved: Int = 0
    private(set) var totalLocationStrips: Int = 0
    private(set) var firstStripDate: Date?
    private(set) var currentStreak: Int = 0

    // MARK: - Computed

    var daysProtecting: Int {
        guard let first = firstStripDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: first, to: .now).day ?? 0
    }

    var hasEarnedFirstStrip: Bool { totalPhotosStripped >= 1 }
    var hasEarned100Badge: Bool { totalPhotosStripped >= 100 }
    var hasEarned1000Badge: Bool { totalPhotosStripped >= 1000 }

    // MARK: - Init

    init() {
        loadStats()
    }

    // MARK: - Record

    func recordStrip(photosCount: Int, fieldsRemoved: Int, hadLocation: Bool) {
        totalPhotosStripped += photosCount
        totalFieldsRemoved += fieldsRemoved
        if hadLocation { totalLocationStrips += photosCount }

        if firstStripDate == nil {
            firstStripDate = .now
            defaults.set(Date.now, forKey: Keys.firstStripDate)
        }

        // Update streak
        updateStreak()

        // Persist
        defaults.set(totalPhotosStripped, forKey: Keys.totalStripped)
        defaults.set(totalFieldsRemoved, forKey: Keys.totalFieldsRemoved)
        defaults.set(totalLocationStrips, forKey: Keys.totalLocationStrips)
    }

    // MARK: - Private

    private func loadStats() {
        totalPhotosStripped = defaults.integer(forKey: Keys.totalStripped)
        totalFieldsRemoved = defaults.integer(forKey: Keys.totalFieldsRemoved)
        totalLocationStrips = defaults.integer(forKey: Keys.totalLocationStrips)
        firstStripDate = defaults.object(forKey: Keys.firstStripDate) as? Date
        currentStreak = defaults.integer(forKey: Keys.currentStreak)
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if let lastDate = defaults.object(forKey: Keys.streakLastDate) as? Date {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDiff == 1 {
                currentStreak += 1
            } else if daysDiff > 1 {
                currentStreak = 1
            }
            // daysDiff == 0 means same day, streak unchanged
        } else {
            currentStreak = 1
        }

        defaults.set(today, forKey: Keys.streakLastDate)
        defaults.set(currentStreak, forKey: Keys.currentStreak)
    }
}
