//
//  GameScene.swift
//  RevengeOfTheSamurai Shared
//
//  Created by x414e54 on 11/02/2021.
//

import AVKit
import SpriteKit

#if os(OSX)
typealias UIColor = NSColor
typealias UIFont = NSFont
#endif

class GameScene: SKScene {

	var gameLogic: GameLogic?
	var data: NSDictionary?
	var nextSceneNode: SKSpriteNode?
	var prevSceneNode: SKSpriteNode?
	var toolbarButtons: [SKSpriteNode] = []
	var gameMenu: GameSubScene?
	var sceneNumberLabel: SKLabelNode?
	
	override func didMove(to view: SKView) {
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
			/*let imagePath = Bundle.main.path(forResource: "NextScene", ofType: ".png")
			nextSceneNode?.texture = SKTexture(imageNamed: imagePath!)
			nextSceneNode?.size = CGSize(width: 40, height: 40)
			nextSceneNode?.position = CGPoint(x: self.frame.maxX - 40, y: self.frame.minY + 40)
			nextSceneNode?.zPosition = 200
			self.addChild(nextSceneNode!)*/
		}
		
		if (prevSceneNode == nil) {
			prevSceneNode = SKSpriteNode()
			/*let imagePath = Bundle.main.path(forResource: "NextScene", ofType: ".png")
			prevSceneNode?.texture = SKTexture(imageNamed: imagePath!)
			prevSceneNode?.size = CGSize(width: 40, height: 40)
			prevSceneNode?.position = CGPoint(x: self.frame.maxX - 40, y: self.frame.minY + 40)
			//prevSceneNode?.zRotation =
			prevSceneNode?.zPosition = 200
			self.addChild(prevSceneNode!)*/
		}
		
		if (toolbarButtons.count == 0) {
			let toolbarPlaceholder = self.childNode(withName: "Toolbar")
			if (toolbarPlaceholder != nil) {
				let menuButton = SKSpriteNode()
				let imagePath = Bundle.main.path(forResource: "Cog", ofType: ".png")
				menuButton.texture = SKTexture(imageNamed: imagePath!)
				menuButton.size = CGSize(width: 40, height: 40)
				menuButton.position = toolbarPlaceholder!.position
				menuButton.zPosition = 200
				self.addChild(menuButton)
				toolbarButtons.append(menuButton)
			}
		}

		if (gameMenu == nil) {
			gameMenu = GameMenuLogic(gameLogic: gameLogic)
			gameMenu?.isHidden = true
			gameMenu?.zPosition = 1000
			self.addChild(gameMenu!)
		}
		
		disablePrevSceneIndicator()
		disableNextSceneIndicator()
		
		// TODO check for presses before this function has run!!!!!
	}
	
	func enablePrevSceneIndicator() {
		// Only allow one move back.
		//prevSceneNode?.isHidden = false
		//prevSceneNode!.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeIn(withDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])))
	}
	
	func enableNextSceneIndicator() {
		//nextSceneNode?.isHidden = false
		//nextSceneNode!.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeIn(withDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])))
	}
	
	func disablePrevSceneIndicator() {
		prevSceneNode!.isHidden = true
		//prevSceneNode?.removeAllActions()
		//prevSceneNode!.alpha = 0.0
	}
	
	func disableNextSceneIndicator() {
		nextSceneNode!.isHidden = true
		//nextSceneNode?.removeAllActions()
		//nextSceneNode!.alpha = 0.0
	}
	
	func addToToolbar() {
		//if (toolbar != ) {
		// toolbarButtons
		//}
	}
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
	}
	
	func handleToolbar(_ point: CGPoint) -> Bool {
		for button in toolbarButtons {
			if (button.frame.contains(point)) {
				gameMenu?.isHidden = false
				return true
			}
		}
		return false
	}
	
	func handleGameMenu(_ point: CGPoint) -> Bool {
		return false
	}
	
	func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		
	}
	
	func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
		
	}
	
	func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		if (handleToolbar(point)) {
			return
		}
		if (gameMenu?.isHidden == false) {
			gameMenu!.interactionEnded(point, timestamp: timestamp)
		} else {
			gameLogic?.nextScene()
		}
	}
}

#if os(iOS) || os(tvOS)
extension GameScene {

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (touches.first != nil) {
			let point: CGPoint = (touches.first?.location(in: self))!
			interactionBegan(point, timestamp: event!.timestamp)
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (touches.first != nil) {
			let point: CGPoint = (touches.first?.location(in: self))!
			interactionMoved(point, timestamp: event!.timestamp)
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (touches.first != nil) {
			let point: CGPoint = (touches.first?.location(in: self))!
			interactionEnded(point, timestamp: event!.timestamp)
		}
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

	override func mouseDown(with event: NSEvent) {
		let point: CGPoint = event.location(in: self)
		interactionBegan(point, timestamp: event.timestamp)
	}
	
	override func mouseDragged(with event: NSEvent) {
		let point: CGPoint = event.location(in: self)
		interactionMoved(point, timestamp: event.timestamp)
	}
	
	override func mouseUp(with event: NSEvent) {
		let point: CGPoint = event.location(in: self)
		interactionEnded(point, timestamp: event.timestamp)
	}

}
#endif
