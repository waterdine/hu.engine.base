import XCTest
@testable import 虎_engine_base

final class 虎_engine_base_tests: XCTestCase {
    func testExample() {
        let productBaseURL = URL(fileURLWithPath: "/Users/ito.antonia/Library/Mobile Documents/iCloud~studio~waterdine~xn--y71a~engine/Documents/ES.teprod")
        let assetPackUrl = URL(fileURLWithPath: "/Users/ito.antonia/Library/Mobile Documents/iCloud~studio~waterdine~xn--y71a~engine/Documents/EvilShogun.tepack")
        let defaultBundle = Bundle.init(url: assetPackUrl)
        let gameLogic = GameLogic.newGame(transitionCallback: nil, baseDir: productBaseURL, aspectSuffix: "iPhone", defaultBundle: defaultBundle)
        //XCTAssertEqual(虎_engine_base().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
