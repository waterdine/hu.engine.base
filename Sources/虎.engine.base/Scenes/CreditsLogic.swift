//
//  CreditsLogic.swift
//  虎.engine.base
//
//  Created by ito.antonia on 13/02/2021.
//

import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class CreditsLogic: GameScene {
	
	var skipable: Bool = false
	
	class func newScene(gameLogic: GameLogic) -> CreditsLogic {
        let scene: CreditsLogic = try! gameLogic.loadScene(scene: "Default.Credits", classType: CreditsLogic.classForKeyedUnarchiver()) as! CreditsLogic
		scene.allowSkipCredits = false
		return scene
	}
	
	override func didMove(to view: SKView) {
		let credits = self.childNode(withName: "//Credits")
		credits?.removeAllActions()
		let startPos = credits?.userData != nil ? credits?.userData!["startPos"] : nil
		credits!.position = CGPoint(x: 0.0, y: startPos != nil ? startPos! as! Double : -320.0)
		credits!.run(SKAction.init(named: "CreditsRoll")!)
		let finalFade = self.childNode(withName: "//FinalFade")
		finalFade?.removeAllActions()
		finalFade?.alpha = 0.0
		if (!skipable) {
			finalFade!.run(SKAction.init(named: "FinalFade")!)
		}
	}
	
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		let credits = self.childNode(withName: "//Credits")
		if (skipable) {
			self.gameLogic?.backToMenu()
		} else if (!credits!.hasActions()) {
			self.gameLogic?.nextScene()
		}
	}
}
