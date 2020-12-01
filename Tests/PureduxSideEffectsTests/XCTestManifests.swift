import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PureduxSideEffectsTests.allTests),
    ]
}
#endif
