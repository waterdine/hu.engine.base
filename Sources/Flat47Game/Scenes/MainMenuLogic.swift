//
//  MainMenuLogic.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
//

import SpriteKit

@available(OSX 10.12, *)
@available(iOS 11.0, *)
class MainMenuLogic: GameScene {
	
	var buttonsNode: SKNode?
	var backgroundNode: SKNode?
	var pressNode: SKLabelNode?
	var playResumeNode: SKNode?
	var fromTheTopNode: SKNode?
	var configNode: SKNode?
	var creditsNode: SKNode?
	
	// Config Popup
	var configPopupNode: SKNode?
	var configCloseNode: SKNode?
	var debugModeNode: SKNode?
	var debugModeLabel: SKLabelNode?
	var puzzleModeNode: SKNode?
	var puzzleModeLabel: SKLabelNode?
	var textSpeedNode: SKNode?
	var textSpeedLabel: SKLabelNode?
	
	// Restart Popup
	var restartPopupNode: SKNode?
	var yesNode: SKNode?
	var noNode: SKNode?
	
	var loaded: Bool = false
	var pressToContinue: Bool = false
	
	class func newScene(gameLogic: GameLogic) -> MainMenuLogic {
		guard let scene = MainMenuLogic(fileNamed: "MainMenu" + gameLogic.getAspectSuffix()) else {
			print("Failed to load MainMenu.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic
		scene.requiresMusic = true
		scene.defaultMusicFile = "Main"
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		buttonsNode = self.childNode(withName: "//Buttons")
		backgroundNode = self.childNode(withName: "//Background")
		pressNode = self.childNode(withName: "//Press") as? SKLabelNode
		playResumeNode = self.childNode(withName: "//PlayResume")
		fromTheTopNode = self.childNode(withName: "//FromTheTop")
		configNode = self.childNode(withName: "//Config")
		creditsNode = self.childNode(withName: "//Credits")
		
		// Config Popup
		configPopupNode = self.childNode(withName: "//ConfigPopup")
		debugModeNode = self.childNode(withName: "//DebugMode")
		puzzleModeNode = self.childNode(withName: "//PuzzleMode")
		textSpeedNode = self.childNode(withName: "//TextSpeed")
		configCloseNode = self.childNode(withName: "//Close")
		debugModeLabel = self.childNode(withName: "//DebugModeLabel") as? SKLabelNode
		puzzleModeLabel = self.childNode(withName: "//PuzzleModeLabel") as? SKLabelNode
		textSpeedLabel = self.childNode(withName: "//TextSpeedLabel") as? SKLabelNode
		
		// Restart Popup
		restartPopupNode = self.childNode(withName: "//RestartPopup")
		yesNode = self.childNode(withName: "//Yes")
		noNode = self.childNode(withName: "//No")
		
		fromTheTopNode?.isHidden = self.gameLogic?.currentSceneIndex == -1 && self.gameLogic?.currentChapterIndex == 0
		let playResumeLabel = self.childNode(withName: "//PlayResumeLabel") as? SKLabelNode
		playResumeLabel!.text = fromTheTopNode!.isHidden ? "Play" : "Continue"
		
		configPopupNode?.isHidden = true
		debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
		#if DEBUG
			debugModeNode!.isHidden = false
		#else
			debugModeNode!.isHidden = true
		#endif
		puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? "Skip Puzzles is On" : "Skip Puzzles is Off"
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
		loaded = false
		pressToContinue = true
		pressNode?.isHidden = false
		let pos = backgroundNode?.userData!["OriginalPos"] as! Int
		backgroundNode?.removeAllActions()
		backgroundNode?.position = CGPoint(x: pos, y: 0)
		buttonsNode?.removeAllActions()
		buttonsNode?.alpha = 0.0
		buttonsNode!.isHidden = false
		pressNode?.removeAllActions()
		pressNode?.run(SKAction(named: "PressToContinueFade")!)
		restartPopupNode?.isHidden = true
	}
	
	// TODO combine the GameMenu and MainMenuConfig into a coherant menu system.
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		if (pressToContinue) {
			if (pressNode!.alpha > 0.0) {
				pressToContinue = false
				if (backgroundNode?.position.x != 0) {
					backgroundNode?.run(SKAction(named: "PressToContinue")!)
					buttonsNode?.run(SKAction(named: "LongFadeIn")!)
				} else {
					buttonsNode?.run(SKAction.fadeIn(withDuration: 1.0))
				}
				pressNode?.removeAllActions()
				pressNode?.run(SKAction.fadeOut(withDuration: 0.3))
			} else {
				pressNode?.run(SKAction.fadeIn(withDuration: 0.3))
			}
		} else if (!restartPopupNode!.isHidden) {
			if (yesNode!.frame.contains(point)) {
				self.gameLogic?.restart()
				restartPopupNode?.isHidden = true
				buttonsNode!.isHidden = true
			} else if (noNode!.frame.contains(point)) {
				restartPopupNode?.isHidden = true
				buttonsNode!.isHidden = false
			}
		} else if (buttonsNode!.alpha >= 0.5 && configPopupNode!.isHidden) {
			if (playResumeNode!.frame.contains(point)) {
				self.gameLogic?.start()
			} else if (!fromTheTopNode!.isHidden && fromTheTopNode!.frame.contains(point)) {
				restartPopupNode?.isHidden = false
				buttonsNode!.isHidden = true
			} else if (configNode!.frame.contains(point)) {
				configPopupNode?.isHidden = false
			} else if (creditsNode!.frame.contains(point)) {
				self.gameLogic?.rollCredits()
			}
		} else if (buttonsNode!.alpha >= 0.5) {
			if (configCloseNode!.frame.contains(point)) {
				configPopupNode?.isHidden = true
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
	
	override open func interactionButton(_ button: GamePadButton, timestamp: TimeInterval) {
		if (button == GamePadButton.CROSS) {
			if (restartPopupNode!.isHidden == false) {
				restartPopupNode?.isHidden = true
				buttonsNode!.isHidden = false
			} else if (configPopupNode!.isHidden == false) {
				configPopupNode!.isHidden = true
			} else if (buttonsNode!.alpha > 0) {
				pressToContinue = true
				pressNode?.isHidden = false
				let pos = backgroundNode?.userData!["OriginalPos"] as! Int
				backgroundNode?.removeAllActions()
				backgroundNode?.position = CGPoint(x: pos, y: 0)
				buttonsNode?.removeAllActions()
				buttonsNode?.alpha = 0.0
				buttonsNode!.isHidden = false
				pressNode?.removeAllActions()
				pressNode?.run(SKAction(named: "PressToContinueFade")!)
			} else if (view!.window!.styleMask.contains(NSWindow.StyleMask.fullScreen)) {
				view?.window?.toggleFullScreen(self)
			}
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		if (!loaded) {
			fromTheTopNode?.isHidden = self.gameLogic?.currentSceneIndex == -1 && self.gameLogic?.currentChapterIndex == 0
			let playResumeLabel = self.childNode(withName: "//PlayResumeLabel") as? SKLabelNode
			//let playResumeLabelShadow = self.childNode(withName: "//PlayResumeLabelShadow") as? SKLabelNode
			playResumeLabel!.text = fromTheTopNode!.isHidden ? "Play" : "Continue"
			//playResumeLabelShadow!.text = playResumeLabel!.text
			debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
			puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? "Skip Puzzles is On" : "Skip Puzzles is Off"
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
			loaded = true
		}
	}
}
