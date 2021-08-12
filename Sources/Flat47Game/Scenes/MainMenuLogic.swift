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

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		scene.requiresMusic = true
		scene.defaultMusicFile = "Main"
		
		return scene
	}
	
	override func didMove(to view: SKView) {
        let title = Bundle.main.localizedString(forKey: "Title", value: nil, table: "Story")
        let titleLabel = self.childNode(withName: "//Title") as? SKLabelNode
        titleLabel?.attributedText = NSMutableAttributedString(string: title, attributes: titleLabel?.attributedText?.attributes(at: 0, effectiveRange: nil))
        let titleShadow1Label = self.childNode(withName: "//TitleShadow1") as? SKLabelNode
        titleShadow1Label?.attributedText = NSMutableAttributedString(string: title, attributes: titleShadow1Label?.attributedText?.attributes(at: 0, effectiveRange: nil))
        let titleShadow2Label = self.childNode(withName: "//TitleShadow2") as? SKLabelNode
        titleShadow2Label?.attributedText = titleShadow1Label?.attributedText
        
        let subTitle = Bundle.main.localizedString(forKey: "Subtitle", value: nil, table: "Story")
        let subTitleLabel = self.childNode(withName: "//Subtitle") as? SKLabelNode
        subTitleLabel?.text = subTitle
        let subTitleShadow1Label = self.childNode(withName: "//SubtitleShadow1") as? SKLabelNode
        subTitleShadow1Label?.text = subTitleLabel?.text
        let subTitleShadow2Label = self.childNode(withName: "//SubtitleShadow2") as? SKLabelNode
        subTitleShadow2Label?.text = subTitleLabel?.text
       
		buttonsNode = self.childNode(withName: "//Buttons")
		backgroundNode = self.childNode(withName: "//Background")
		pressNode = self.childNode(withName: "//Press") as? SKLabelNode
		playResumeNode = self.childNode(withName: "//PlayResume")
		fromTheTopNode = self.childNode(withName: "//FromTheTop")
		configNode = self.childNode(withName: "//Config")
		creditsNode = self.childNode(withName: "//Credits")
        let fromTheTopLabel = self.childNode(withName: "//FromTheTopLabel") as? SKLabelNode
        fromTheTopLabel?.text = Bundle.main.localizedString(forKey: "Restart", value: nil, table: "Story")
        let configLabel = self.childNode(withName: "//ConfigLabel") as? SKLabelNode
        configLabel?.text = Bundle.main.localizedString(forKey: "Setup", value: nil, table: "Story")
        let creditsLabel = self.childNode(withName: "//CreditsLabel") as? SKLabelNode
        creditsLabel?.text = Bundle.main.localizedString(forKey: "Credits", value: nil, table: "Story")
        pressNode?.text = Bundle.main.localizedString(forKey: "Press to continue...", value: nil, table: "Story")
		
		// Config Popup
		configPopupNode = self.childNode(withName: "//ConfigPopup")
		debugModeNode = self.childNode(withName: "//DebugMode")
		puzzleModeNode = self.childNode(withName: "//PuzzleMode")
		textSpeedNode = self.childNode(withName: "//TextSpeed")
		configCloseNode = self.childNode(withName: "//Close")
		debugModeLabel = self.childNode(withName: "//DebugModeLabel") as? SKLabelNode
		puzzleModeLabel = self.childNode(withName: "//PuzzleModeLabel") as? SKLabelNode
		textSpeedLabel = self.childNode(withName: "//TextSpeedLabel") as? SKLabelNode
        let configCloseLabel = self.childNode(withName: "//CloseLabel") as? SKLabelNode
        configCloseLabel?.text = Bundle.main.localizedString(forKey: "Close", value: nil, table: "Story")
		
		// Restart Popup
		restartPopupNode = self.childNode(withName: "//RestartPopup")
		yesNode = self.childNode(withName: "//Yes")
		noNode = self.childNode(withName: "//No")
        let yesLabel = self.childNode(withName: "//YesLabel") as? SKLabelNode
        yesLabel?.text = Bundle.main.localizedString(forKey: "Yes", value: nil, table: "Story")
        let noLabel = self.childNode(withName: "//NoLabel") as? SKLabelNode
        noLabel?.text = Bundle.main.localizedString(forKey: "No", value: nil, table: "Story")
        let restartGameLabel = self.childNode(withName: "//RestartText1") as? SKLabelNode
        restartGameLabel?.text = Bundle.main.localizedString(forKey: "Restart the game!", value: nil, table: "Story")
        let restartGameShadow1Label = self.childNode(withName: "//RestartText1Shadow1") as? SKLabelNode
        restartGameShadow1Label?.text = restartGameLabel?.text
        let restartGameShadow2Label = self.childNode(withName: "//RestartText1Shadow2") as? SKLabelNode
        restartGameShadow2Label?.text = restartGameLabel?.text
        let areYouSureLabel = self.childNode(withName: "//RestartText2") as? SKLabelNode
        areYouSureLabel?.text = Bundle.main.localizedString(forKey: "Are you sure?", value: nil, table: "Story")
        let areYouSureShadow1Label = self.childNode(withName: "//RestartText2Shadow1") as? SKLabelNode
        areYouSureShadow1Label?.text = areYouSureLabel?.text
        let areYouSureShadow2Label = self.childNode(withName: "//RestartText2Shadow2") as? SKLabelNode
        areYouSureShadow2Label?.text = areYouSureLabel?.text
		
		fromTheTopNode?.isHidden = self.gameLogic?.currentSceneIndex == -1 && self.gameLogic?.currentChapterIndex == 0
		let playResumeLabel = self.childNode(withName: "//PlayResumeLabel") as? SKLabelNode
		playResumeLabel!.text = fromTheTopNode!.isHidden ? Bundle.main.localizedString(forKey: "Play", value: nil, table: "Story") : Bundle.main.localizedString(forKey: "Continue", value: nil, table: "Story")
		
		configPopupNode?.isHidden = true
		debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
		#if DEBUG
			debugModeNode!.isHidden = false
		#else
			debugModeNode!.isHidden = true
		#endif
		puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? Bundle.main.localizedString(forKey: "Skip Puzzles is On", value: nil, table: "Story") : Bundle.main.localizedString(forKey: "Skip Puzzles is Off", value: nil, table: "Story")
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
			}
		}
	}
	
	override open func interactionButton(_ button: GamePadButton, timestamp: TimeInterval) {
#if os(OSX)
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
#endif
	}
	
	override func update(_ currentTime: TimeInterval) {
		if (!loaded) {
			fromTheTopNode?.isHidden = self.gameLogic?.currentSceneIndex == -1 && self.gameLogic?.currentChapterIndex == 0
			let playResumeLabel = self.childNode(withName: "//PlayResumeLabel") as? SKLabelNode
			//let playResumeLabelShadow = self.childNode(withName: "//PlayResumeLabelShadow") as? SKLabelNode
			playResumeLabel!.text = fromTheTopNode!.isHidden ? Bundle.main.localizedString(forKey: "Play", value: nil, table: "Story") : Bundle.main.localizedString(forKey: "Continue", value: nil, table: "Story")
			//playResumeLabelShadow!.text = playResumeLabel!.text
			debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
			puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? Bundle.main.localizedString(forKey: "Skip Puzzles is On", value: nil, table: "Story") : Bundle.main.localizedString(forKey: "Skip Puzzles is Off", value: nil, table: "Story")
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
			loaded = true
		}
	}
}
