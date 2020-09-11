import XCTest
@testable import SwiftRX

final class SwiftRXTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftRX().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
