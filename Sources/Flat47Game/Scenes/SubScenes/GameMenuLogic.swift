//
//  GameMenuLogic.swift
//  RevengeOfTheSamurai
//
//  Created by x414e54 on 16/06/2021.
//

import SpriteKit

class GameMenuLogic : GameSubScene {
	
	// TODO Do not do OOP, until plan for a more functionally driven engine has emerged use OOP.
	
	// GameMenuButtons Popup
	var mainMenuNode: SKNode? // GameButton (SubScene)
	var closeNode: SKNode?
	var debugModeNode: SKNode?
	var debugModeLabel: SKLabelNode?
	var puzzleModeNode: SKNode?
	var puzzleModeLabel: SKLabelNode?
	var textSpeedNode: SKNode?
	var textSpeedLabel: SKLabelNode?
	
	public override init(gameLogic: GameLogic?) {
		super.init(gameLogic: gameLogic)
	   // TODO combine these into one thing GameSubScene and its logic.
	   // Inheritance is still possible in functional design.
	   // Firstly its like a struct, it can be extended. So create a dataset that has the positions or layouts of the items, to replace .sks files.
	   // This will then work like SwiftUI (what hook in with crossplatform SwiftUI can there be?).
	   // There should be a viewer and editor similar to the original SceneKit editor.
	   // Think about graph based/logic based. In memory it is a graph based representation, can it be insta loaded into memory, code can do that.
	   // Render through via the code.
	   // Then any asset can be used as long as it is inside the "sandbox"/api for that content.
	   // Content and code become the same? Just use the same compression for all, using a raw type. Blocks are compressed.
	   // Bake down the entire codebase (which includes raw text driven assets).
	   // That is then aligned to a physical layer format, which can be loaded into memory in chunks as requested. Or all at once.
	   // Etc.
	   let subScene = SKNode(fileNamed: "GameMenu" + (gameLogic?.getAspectSuffix())!)
	   let gameMenu = subScene?.childNode(withName: "//ConfigPopup")
	   gameMenu?.removeFromParent()
	   self.addChild(gameMenu!)
	   mainMenuNode = self.childNode(withName: "//MainMenu")
	   closeNode = self.childNode(withName: "//Close")
	   debugModeNode = self.childNode(withName: "//DebugMode")
	   debugModeLabel = self.childNode(withName: "//DebugModeLabel") as? SKLabelNode
	   puzzleModeNode = self.childNode(withName: "//PuzzleMode")
	   puzzleModeLabel = self.childNode(withName: "//PuzzleModeLabel") as? SKLabelNode
	   textSpeedNode = self.childNode(withName: "//TextSpeed")
	   textSpeedLabel = self.childNode(withName: "//TextSpeedLabel") as? SKLabelNode
	   #if !DEBUG
		   debugModeNode?.isHidden = true
	   #endif
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		if (mainMenuNode!.frame.contains(point)) {
			self.isHidden = true
			gameLogic?.backToMenu()
		} else if (closeNode!.frame.contains(point)) {
			self.isHidden = true
		} else if (debugModeNode!.frame.contains(point)) {
			self.gameLogic!.sceneDebug = !self.gameLogic!.sceneDebug
			self.gameLogic!.saveState()
			debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
		} else if (puzzleModeNode!.frame.contains(point)) {
			self.gameLogic!.skipPuzzles = !self.gameLogic!.skipPuzzles
			self.gameLogic!.saveState()
			puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? "Skip Puzzles is On" : "Skip Puzzles is Off"
		} else if (textSpeedNode!.frame.contains(point)) {
			self.gameLogic!.nextTextSpeed()
			switch self.gameLogic!.textSpeed {
			case .Slow:
				textSpeedLabel!.text = "Text Speed: Slow"
				break
			case .Normal:
				textSpeedLabel!.text = "Text Speed: Normal"
				break
			case .Fast:
				textSpeedLabel!.text = "Text Speed: Fast"
				break
			}
		}
	}
}
