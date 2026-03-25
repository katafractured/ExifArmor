import XCTest
@testable import ExifArmor

/// Tests for FreeTierManager — daily strip limit enforcement.
final class FreeTierManagerTests: XCTestCase {

    private var manager: FreeTierManager!

    override func setUp() {
        super.setUp()
        // Clear stored state before each test
        UserDefaults.standard.removeObject(forKey: "freeStripCountToday")
        UserDefaults.standard.removeObject(forKey: "freeStripDate")
        manager = FreeTierManager()
    }

    func testInitialStateHasFullStrips() {
        XCTAssertEqual(manager.stripsRemaining, 5)
        XCTAssertEqual(manager.stripsUsedToday, 0)
        XCTAssertFalse(manager.hasReachedLimit)
    }

    func testCanStripWhenUnderLimit() {
        XCTAssertTrue(manager.canStrip(isPro: false))
    }

    func testProAlwaysCanStrip() {
        // Use up all free strips
        manager.recordStrips(count: 5, isPro: false)
        XCTAssertTrue(manager.canStrip(isPro: true))
    }

    func testRecordStripsDecrementsRemaining() {
        manager.recordStrips(count: 3, isPro: false)
        XCTAssertEqual(manager.stripsUsedToday, 3)
        XCTAssertEqual(manager.stripsRemaining, 2)
    }

    func testReachesLimitAfterFiveStrips() {
        manager.recordStrips(count: 5, isPro: false)
        XCTAssertTrue(manager.hasReachedLimit)
        XCTAssertFalse(manager.canStrip(isPro: false))
        XCTAssertEqual(manager.stripsRemaining, 0)
    }

    func testDoesNotTrackProStrips() {
        manager.recordStrips(count: 100, isPro: true)
        XCTAssertEqual(manager.stripsUsedToday, 0, "Pro strips should not count against free limit")
    }

    func testRemainingNeverGoesNegative() {
        manager.recordStrips(count: 10, isPro: false)
        XCTAssertEqual(manager.stripsRemaining, 0, "Remaining should floor at 0")
    }
}
