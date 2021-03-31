//
//  GameScene.swift
//  RevengeOfTheSamurai Shared
//
//  Created by x414e54 on 11/02/2021.
//

import AVKit
import SpriteKit

@available(iOS 10.0, *)
open class GameScene: SKScene {

	open var gameLogic: GameLogic?
	open var data: NSDictionary?
	var nextSceneNode: SKSpriteNode?
	var sceneNumberLabel: SKLabelNode?
	
	open override func didMove(to view: SKView) {
		let logic: GameLogic = gameLogic!
		if (logic.sceneDebug) {
			let sceneNumber: Int = logic.currentSceneIndex!
			let sceneNumberText = String.init(format: "Scene: %d", sceneNumber as CVarArg)
			if (sceneNumberLabel == nil) {
				sceneNumberLabel = SKLabelNode.init(text: sceneNumberText)
				sceneNumberLabel?.name = "SceneNumber"
				sceneNumberLabel!.zPosition = 100.0
				sceneNumberLabel?.fontColor = UIColor.red
				sceneNumberLabel?.fontSize = 14
				sceneNumberLabel?.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
				sceneNumberLabel?.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
				sceneNumberLabel?.fontName = "Arial Bold"
				sceneNumberLabel!.position = CGPoint(x: self.frame.minX, y: self.frame.maxY)
				self.addChild(sceneNumberLabel!)
			} else {
				sceneNumberLabel?.text = sceneNumberText
			}
		} else if (sceneNumberLabel != nil) {
			sceneNumberLabel?.removeFromParent()
		}
		
		if (nextSceneNode == nil) {
			nextSceneNode = SKSpriteNode()
			let imagePath = Bundle.main.path(forResource: "NextScene", ofType: ".png")
			nextSceneNode?.texture = SKTexture(imageNamed: imagePath!)
			nextSceneNode?.size = CGSize(width: 40, height: 40)
			nextSceneNode?.position = CGPoint(x: self.frame.maxX - 40, y: self.frame.minY + 40)
			nextSceneNode?.zPosition = 200
			self.addChild(nextSceneNode!)
		}
		disableNextSceneIndicator()
    }
    
	open func enableNextSceneIndicator() {
		//nextSceneNode?.isHidden = false
		//nextSceneNode!.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeIn(withDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])))
	}
	
	open func disableNextSceneIndicator() {
		nextSceneNode!.isHidden = true
		nextSceneNode?.removeAllActions()
		nextSceneNode!.alpha = 0.0
	}
	
	open override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
	
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
 
	open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
 
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		gameLogic?.nextScene()
	}
 
	open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
}
