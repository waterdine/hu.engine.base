//
//  SkipBack.swift
//  虎.engine.base
//
//  Created by ito.antonia on 17/06/2021.
//

import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class SkipBackLogic: GameScene {
    
    class func newScene(gameLogic: GameLogic) -> SkipBackLogic {
        let scene = SkipBackLogic()

        scene.scaleMode = gameLogic.getScaleMode()
        scene.gameLogic = gameLogic
        
        return scene
    }
    
    open override func customLogic() -> Bool {
        let flag: String? = (data as? SkipToScene)!.Flag
         
        var shouldSkip: Bool = true;
         
        if (flag != nil) {
            shouldSkip = !(gameLogic!.flags.contains(flag!))
        }
         
        if (shouldSkip) {
            gameLogic!.popStack()
        } else {
            gameLogic!.nextScene()
        }
        return true
    }
}
