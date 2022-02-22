import XCTest
@testable import 虎_engine_base
import SpriteKit

final class 虎_engine_base_tests: XCTestCase {
    func testExample() {
        let productBaseURL = URL(fileURLWithPath: "/Users/ito.antonia/Library/Mobile Documents/iCloud~studio~waterdine~xn--y71a~engine/Documents/RevengeOfTheSamurai.虎product")
        let assetPackUrl = URL(fileURLWithPath: "/Users/ito.antonia/Library/Mobile Documents/iCloud~studio~waterdine~xn--y71a~engine/Documents/Kamakura.虎library")
        let defaultBundle = Bundle.init(url: assetPackUrl)
        print(productBaseURL.path)
        let gameLogic = GameLogic.newGame(transitionCallback: nil, baseDir: productBaseURL, aspectSuffix: "iPhone", defaultBundle: defaultBundle, languages: ["en","ja"])
        var action = gameLogic.loadAction(actionName: "PressToContinueFade", forResource: "Default.MyActions")!
        //XCTAssertEqual(虎_engine_base().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
