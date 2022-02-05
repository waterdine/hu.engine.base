//
//  GameMenuLogic.swift
//  虎.engine.base Scenes
//
//  Created by A. A. Bills on 16/06/2021.
//

import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class GameMenuLogic : GameSubScene {
	
	// atode: Do not do OOP, until plan for a more functionally driven engine has emerged use OOP.
	
	// GameMenuButtons Popup
	var mainMenuNode: SKNode? // GameButton (SubScene)
	var closeNode: SKNode?
	var debugModeNode: SKNode?
	var debugModeLabel: SKLabelNode?
	var puzzleModeNode: SKNode?
	var puzzleModeLabel: SKLabelNode?
	var textSpeedNode: SKNode?
	var textSpeedLabel: SKLabelNode?
    var volumeNode: SKNode?
    var volumeLabel: SKLabelNode?
	
	public override init(gameLogic: GameLogic?) {
       super.init(gameLogic: gameLogic)
	   // atode: combine these into one thing GameSubScene and its logic.
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
       let buttonFont = Bundle.main.localizedString(forKey: "ButtonFontName", value: nil, table: "Story")
	   let subScene = SKNode(fileNamed: "GameMenu" + (gameLogic?.getAspectSuffix())!)
	   let gameMenu = subScene?.childNode(withName: "//ConfigPopup")
	   gameMenu?.removeFromParent()
	   self.addChild(gameMenu!)
	   mainMenuNode = self.childNode(withName: "//MainMenu")
       let mainMenuLabel = self.childNode(withName: "//MainMenuLabel") as? SKLabelNode
       mainMenuLabel?.text = Bundle.main.localizedString(forKey: "Main Menu", value: nil, table: "Story")
       mainMenuLabel?.fontName = buttonFont
	   closeNode = self.childNode(withName: "//Close")
       let closeLabel = self.childNode(withName: "//CloseLabel") as? SKLabelNode
       closeLabel?.text = Bundle.main.localizedString(forKey: "Close", value: nil, table: "Story")
       closeLabel?.fontName = buttonFont
	   debugModeNode = self.childNode(withName: "//DebugMode")
	   debugModeLabel = self.childNode(withName: "//DebugModeLabel") as? SKLabelNode
       debugModeLabel?.fontName = buttonFont
	   puzzleModeNode = self.childNode(withName: "//PuzzleMode")
	   puzzleModeLabel = self.childNode(withName: "//PuzzleModeLabel") as? SKLabelNode
       puzzleModeLabel?.fontName = buttonFont
	   textSpeedNode = self.childNode(withName: "//TextSpeed")
	   textSpeedLabel = self.childNode(withName: "//TextSpeedLabel") as? SKLabelNode
       textSpeedLabel?.fontName = buttonFont
       switch self.gameLogic!.textSpeed {
       case .Slow:
           textSpeedLabel!.text = Bundle.main.localizedString(forKey: "Text Speed: Slow", value: nil, table: "Story")
           break
       case .Normal:
           textSpeedLabel!.text = Bundle.main.localizedString(forKey: "Text Speed: Normal", value: nil, table: "Story")
           break
       case .Fast:
           textSpeedLabel!.text = Bundle.main.localizedString(forKey: "Text Speed: Fast", value: nil, table: "Story")
           break
       }
       volumeNode = self.childNode(withName: "//Volume")
       volumeLabel = self.childNode(withName: "//VolumeLabel") as? SKLabelNode
       if (volumeLabel != nil) {
           volumeLabel?.fontName = buttonFont
           switch self.gameLogic!.volumeLevel {
           case .Off:
               volumeLabel!.text = Bundle.main.localizedString(forKey: "Volume: Off", value: nil, table: "Story")
               break
           case .Low:
               volumeLabel!.text = Bundle.main.localizedString(forKey: "Volume: Low", value: nil, table: "Story")
               break
           case .Medium:
               volumeLabel!.text = Bundle.main.localizedString(forKey: "Volume: Medium", value: nil, table: "Story")
               break
           case .High:
               volumeLabel!.text = Bundle.main.localizedString(forKey: "Volume: High", value: nil, table: "Story")
               break
           }
       }
       #if !DEBUG
		   debugModeNode?.isHidden = true
	   #endif
       debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
       puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? Bundle.main.localizedString(forKey: "Skip Puzzles is On", value: nil, table: "Story") : Bundle.main.localizedString(forKey: "Skip Puzzles is Off", value: nil, table: "Story")
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
			puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? Bundle.main.localizedString(forKey: "Skip Puzzles is On", value: nil, table: "Story") : Bundle.main.localizedString(forKey: "Skip Puzzles is Off", value: nil, table: "Story")
		} else if (textSpeedNode!.frame.contains(point)) {
			self.gameLogic!.nextTextSpeed()
			switch self.gameLogic!.textSpeed {
            case .Slow:
                textSpeedLabel!.text = Bundle.main.localizedString(forKey: "Text Speed: Slow", value: nil, table: "Story")
                break
            case .Normal:
                textSpeedLabel!.text = Bundle.main.localizedString(forKey: "Text Speed: Normal", value: nil, table: "Story")
                break
            case .Fast:
                textSpeedLabel!.text = Bundle.main.localizedString(forKey: "Text Speed: Fast", value: nil, table: "Story")
                break
			}
		} else if (volumeNode!.frame.contains(point)) {
            self.gameLogic!.nextVolumeLevel()
            switch self.gameLogic!.volumeLevel {
            case .Off:
                volumeLabel!.text = Bundle.main.localizedString(forKey: "Volume: Off", value: nil, table: "Story")
                break
            case .Low:
                volumeLabel!.text = Bundle.main.localizedString(forKey: "Volume: Low", value: nil, table: "Story")
                break
            case .Medium:
                volumeLabel!.text = Bundle.main.localizedString(forKey: "Volume: Medium", value: nil, table: "Story")
                break
            case .High:
                volumeLabel!.text = Bundle.main.localizedString(forKey: "Volume: High", value: nil, table: "Story")
                break
            }
        }
	}
}
