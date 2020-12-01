import XCTest
@testable import PureduxSideEffects

final class PureduxSideEffectsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(PureduxSideEffects().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
