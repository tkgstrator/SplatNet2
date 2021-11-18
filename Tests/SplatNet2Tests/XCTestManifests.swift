import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(SplatNet2Tests.allTests),
    ]
}
#endif
