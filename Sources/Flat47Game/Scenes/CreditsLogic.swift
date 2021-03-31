//
//  CreditsLogic.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 13/02/2021.
//

import SpriteKit
import GameplayKit

class CreditsLogic: GameScene {
	
	var skipable: Bool = false
	
	class func newScene(gameLogic: GameLogic) -> CreditsLogic {
		guard let scene = CreditsLogic(fileNamed: "Credits" + gameLogic.getAspectSuffix()) else {
			print("Failed to load Credits.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic;
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		let credits = self.childNode(withName: "//Credits")
		credits?.removeAllActions()
		credits!.position = CGPoint(x: 0.0, y: -320.0)
		credits!.run(SKAction.init(named: "CreditsRoll")!)
		let finalFade = self.childNode(withName: "//FinalFade")
		finalFade?.removeAllActions()
		finalFade?.alpha = 0.0
		if (!skipable) {
			finalFade!.run(SKAction.init(named: "FinalFade")!)
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let credits = self.childNode(withName: "//Credits")
		if (skipable) {
			self.gameLogic?.backToMenu()
		} else if (!credits!.hasActions()) {
			self.gameLogic?.nextScene()
		}
	}
}
