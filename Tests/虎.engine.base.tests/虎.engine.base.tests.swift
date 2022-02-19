import XCTest
@testable import 虎_engine_base

final class 虎_engine_base_tests: XCTestCase {
    func testExample() {
        let productBaseURL = URL(fileURLWithPath: "/Users/ito.antonia/Library/Mobile Documents/iCloud~studio~waterdine~xn--y71a~engine/Documents/EvilShogun.虎product")
        let assetPackUrl = URL(fileURLWithPath: "/Users/ito.antonia/Library/Mobile Documents/iCloud~studio~waterdine~xn--y71a~engine/Documents/Kamakura.虎library")
        let defaultBundle = Bundle.init(url: assetPackUrl)
        let gameLogic = GameLogic.newGame(transitionCallback: nil, baseDir: productBaseURL, aspectSuffix: "iPhone", defaultBundle: defaultBundle, languages: ["en","ja"])
        //XCTAssertEqual(虎_engine_base().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
