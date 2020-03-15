import XCTest
@testable import CoronaTrackerData

final class CoronaTrackerDataTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CoronaTrackerData().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
