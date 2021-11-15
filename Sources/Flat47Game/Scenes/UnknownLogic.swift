//
//  UnknownLogic.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 13/02/2021.
//

import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class UnknownLogic: GameScene {
	
	class func newScene(gameLogic: GameLogic) -> UnknownLogic {
		guard let scene = UnknownLogic(fileNamed: "Unknown" + gameLogic.getAspectSuffix()) else {
			print("Failed to load Unknown.sks")
			abort()
		}

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		
		return scene
	}
}
