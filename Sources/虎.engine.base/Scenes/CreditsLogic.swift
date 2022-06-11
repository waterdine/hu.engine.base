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
        let scene: CreditsLogic = gameLogic.loadScene(scene: "Default.Credits", resourceBundle: "虎.engine.base", classType: CreditsLogic.classForKeyedUnarchiver()) as! CreditsLogic
		scene.allowSkipCredits = false
		return scene
	}
	
	override func didMove(to view: SKView) {
		let credits = self.childNode(withName: "//Credits")
		credits?.removeAllActions()
		let startPos = credits?.userData != nil ? credits?.userData!["startPos"] : nil
		credits!.position = CGPoint(x: 0.0, y: startPos != nil ? startPos! as! Double : -320.0)
        credits!.run((gameLogic?.loadAction(actionName: "CreditsRoll", forResource: "Default.MyActions"))!)
		let finalFade = self.childNode(withName: "//FinalFade")
		finalFade?.removeAllActions()
		finalFade?.alpha = 0.0
		if (!skipable) {
			finalFade!.run((gameLogic?.loadAction(actionName: "FinalFade", forResource: "Default.MyActions"))!)
		}
        
        let creditNode = credits?.childNode(withName: "//Credit")
        if (creditNode != nil) {
            var offset = 0.0
            for credit in gameLogic!.story!.Credits {
                let creditNode = credits!.childNode(withName: "//Credit")!.copy() as! SKNode
                let titleNode = creditNode.childNode(withName: "//Name") as! SKLabelNode
                let nameNode = creditNode.childNode(withName: "//Title") as! SKLabelNode
                creditNode.position.y -= offset
                titleNode.text = credit.title
                nameNode.text = credit.name
                credits?.addChild(creditNode)
                offset += 2 * nameNode.frame.height
            }
            creditNode?.isHidden = true
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
    
    override func interactionButton(_ button: GamePadButton, timestamp: TimeInterval) {
        interactionEnded(CGPoint(), timestamp: timestamp)
    }
}
