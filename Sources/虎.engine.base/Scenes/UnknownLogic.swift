//
//  UnknownLogic.swift
//  虎.engine.base iOS
//
//  Created by ito.antonia on 13/02/2021.
//

import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class UnknownLogic: GameScene {
	
	class func newScene(gameLogic: GameLogic) -> UnknownLogic {
		guard let scene = UnknownLogic(fileNamed: gameLogic.loadUrl(forResource: gameLogic.appendAspectSuffix(scene: "Default.Unknown"), withExtension: ".sks", subdirectory: "Scenes/" + gameLogic.getAspectSuffix())!.path) else {
			print("Failed to load Unknown.sks")
			abort()
		}

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		
		return scene
	}
}
