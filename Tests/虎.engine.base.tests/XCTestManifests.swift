import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(虎_engine_base_tests.allTests),
    ]
}
#endif
