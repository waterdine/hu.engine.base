//
//  SkipTo.swift
//  虎.engine.base
//
//  Created by ito.antonia on 17/06/2021.
//

import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class SkipToLogic: GameScene {
	
	class func newScene(gameLogic: GameLogic) -> SkipToLogic {
		let scene = SkipToLogic()

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		
		return scene
	}
	
	open override func customLogic() -> Bool {
        let skipToScene: Int = (data as? SkipToScene)!.SkipTo
        let flag: String? = (data as? SkipToScene)!.Flag
		 
		var shouldSkip: Bool = true;
		 
		if (flag != nil) {
			shouldSkip = !(gameLogic!.flags.contains(flag!))
		}
		 
		if (shouldSkip) {
			gameLogic!.setScene(index: skipToScene)
		} else {
			gameLogic!.setScene(index: gameLogic!.currentSceneIndex! + 1)
		}
		return true
	}
}
