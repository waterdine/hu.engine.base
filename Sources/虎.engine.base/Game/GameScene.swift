//
//  GameScene.swift
//  虎.engine.base Game
//
//  Created by ito.antonia on 11/02/2021.
//

import AVKit
import SpriteKit

#if os(OSX)
typealias UIColor = NSColor
typealias UIFont = NSFont
#endif

public enum GamePadButton {
	case UP
	case DOWN
	case LEFT
	case RIGHT
	case CIRCLE
	case CROSS
	case UNKNOWN
}

open class GameTexture: SKTexture {
    /*override public init(texture: SKTexture?, color: NSColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        print ("here")
    }*/
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let obj = aDecoder.attributeKeys
        print (obj)
    }
}

@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class GameScene: SKScene {

	open var gameLogic: GameLogic?
	open var data: BaseScene?
	open var nextSceneNode: SKSpriteNode?
	open var prevSceneNode: SKSpriteNode?
	var toolbarButtons: [SKSpriteNode] = []
	open var gameMenu: GameSubScene?
	var sceneNumberLabel: SKLabelNode?
	
	open var requiresMusic: Bool = false
	open var defaultTransition: Bool = false
	open var allowSkipCredits: Bool = true
	open var defaultMusicFile: String = "Music"
	
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
                let imagePath = gameLogic?.loadUrl(forResource: "Default.Cog", withExtension: ".png", subdirectory: "Images")?.path
				menuButton.texture = SKTexture(imageNamed: imagePath!)
				menuButton.size = CGSize(width: 40, height: 40)
				menuButton.position = toolbarPlaceholder!.position
				menuButton.zPosition = 200
				menuButton.xScale = toolbarPlaceholder!.xScale
				menuButton.yScale = toolbarPlaceholder!.yScale
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
		
		// atode: check for presses before this function has run!!!!!
	}
	
	open func enablePrevSceneIndicator() {
		// Only allow one move back.
		//prevSceneNode?.isHidden = false
		//prevSceneNode!.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeIn(withDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])))
	}
	
	open func enableNextSceneIndicator() {
		//nextSceneNode?.isHidden = false
		//nextSceneNode!.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeIn(withDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])))
	}
	
	open func disablePrevSceneIndicator() {
		prevSceneNode!.isHidden = true
		//prevSceneNode?.removeAllActions()
		//prevSceneNode!.alpha = 0.0
	}
	
	open func disableNextSceneIndicator() {
		nextSceneNode!.isHidden = true
		//nextSceneNode?.removeAllActions()
		//nextSceneNode!.alpha = 0.0
	}
	
	func addToToolbar() {
		//if (toolbar != ) {
		// toolbarButtons
		//}
	}
	
	open override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
	}
	
	open func customLogic() -> Bool {
		return false
	}
	
	open func handleToolbar(_ point: CGPoint) -> Bool {
		for button in toolbarButtons {
			if (button.frame.contains(point)) {
				return true
			}
		}
		return false
	}
	
	func handleGameMenu(_ point: CGPoint) -> Bool {
		return false
	}
	
	open func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		
	}
	
	open func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
		
	}
	
	open func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		if (handleToolbar(point)) {
			gameMenu?.isHidden = false
			return
		}
		if (gameMenu?.isHidden == false) {
			gameMenu!.interactionEnded(point, timestamp: timestamp)
		} else {
			gameLogic?.nextScene()
		}
	}
	
	open func interactionButton(_ button: GamePadButton, timestamp: TimeInterval) {
#if os(OSX)
		if (button == GamePadButton.CROSS) {
			if (gameMenu?.isHidden == false) {
				gameMenu?.isHidden = true
            } else if (view != nil && view!.window != nil && view!.window!.styleMask.contains(NSWindow.StyleMask.fullScreen)) {
				view?.window?.toggleFullScreen(self)
			}
		}
#endif
	}
	
#if os(iOS) || os(tvOS)
	open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (touches.first != nil) {
			let point: CGPoint = (touches.first?.location(in: self))!
			interactionBegan(point, timestamp: event!.timestamp)
		}
	}
	
	open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (touches.first != nil) {
			let point: CGPoint = (touches.first?.location(in: self))!
			interactionMoved(point, timestamp: event!.timestamp)
		}
	}
	
	open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (touches.first != nil) {
			let point: CGPoint = (touches.first?.location(in: self))!
			interactionEnded(point, timestamp: event!.timestamp)
		}
	}
	
	open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
	}
#endif

#if os(OSX)
// Mouse-based event handling
	open override func mouseDown(with event: NSEvent) {
		let point: CGPoint = event.location(in: self)
		interactionBegan(point, timestamp: event.timestamp)
	}
	
	open override func mouseDragged(with event: NSEvent) {
		let point: CGPoint = event.location(in: self)
		interactionMoved(point, timestamp: event.timestamp)
	}
	
	open override func mouseUp(with event: NSEvent) {
		let point: CGPoint = event.location(in: self)
		interactionEnded(point, timestamp: event.timestamp)
	}

	open override func keyDown(with event: NSEvent) {
		var button: GamePadButton
		switch event.keyCode {
		case 126:
			button = GamePadButton.UP
			break
		case 125:
			button = GamePadButton.DOWN
			break
		case 123:
			button = GamePadButton.LEFT
			break
		case 124:
			button = GamePadButton.RIGHT
			break
		case 76,  36, 49:
			button = GamePadButton.CIRCLE
		case 53:
			button = GamePadButton.CROSS
			break
		default:
			button = GamePadButton.UNKNOWN
		}
		interactionButton(button, timestamp: event.timestamp)
	}
#endif
	
}
