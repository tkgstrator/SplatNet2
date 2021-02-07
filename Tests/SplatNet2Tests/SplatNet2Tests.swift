import XCTest
@testable import SplatNet2

final class SplatNet2Tests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SplatNet2().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
