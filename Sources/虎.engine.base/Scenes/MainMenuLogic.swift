//
//  MainMenuLogic.swift
//  虎.engine.base iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
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
    var volumeNode: SKNode?
    var volumeLabel: SKLabelNode?
    var languageNode: SKNode?
    var languageLabel: SKLabelNode?
	
	// Restart Popup
	var restartPopupNode: SKNode?
	var yesNode: SKNode?
	var noNode: SKNode?
	
	var loaded: Bool = false
	var pressToContinue: Bool = false
    
    var selectedNode: SKNode? = nil
	
	class func newScene(gameLogic: GameLogic) -> MainMenuLogic {
        let scene: MainMenuLogic = gameLogic.loadScene(scene: "Default.MainMenu", resourceBundle: "虎.engine.base", classType: MainMenuLogic.classForKeyedUnarchiver()) as! MainMenuLogic
		scene.requiresMusic = true
		scene.defaultMusicFile = "Main"
		return scene
	}
	
	override func didMove(to view: SKView) {
        var title = gameLogic!.localizedString(forKey: "Title", value: nil, table: "Story")
        let titleLabel = self.childNode(withName: "//Title") as? SKLabelNode
        if (title.isEmpty) {
            title = "Title"
        }
        
        if #available(iOS 11.0, tvOS 11.0, *) {
            titleLabel?.attributedText = NSMutableAttributedString(string: title, attributes: titleLabel?.attributedText?.attributes(at: 0, effectiveRange: nil))
        } else {
            // Fallback on earlier versions
        }
        let titleShadow1Label = self.childNode(withName: "//TitleShadow1") as? SKLabelNode
        if #available(iOS 11.0, tvOS 11.0, *) {
            titleShadow1Label?.attributedText = NSMutableAttributedString(string: title, attributes: titleShadow1Label?.attributedText?.attributes(at: 0, effectiveRange: nil))
        } else {
            // Fallback on earlier versions
        }
        let titleShadow2Label = self.childNode(withName: "//TitleShadow2") as? SKLabelNode
        if #available(iOS 11.0, tvOS 11.0, *) {
            titleShadow2Label?.attributedText = titleShadow1Label?.attributedText
        } else {
            // Fallback on earlier versions
        }
        
        var subTitle = gameLogic!.localizedString(forKey: "Subtitle", value: nil, table: "Story")
        if (subTitle.isEmpty) {
            subTitle = "Subtitle"
        }
        let subTitleLabel = self.childNode(withName: "//Subtitle") as? SKLabelNode
        subTitleLabel?.text = subTitle
        let subTitleShadow1Label = self.childNode(withName: "//SubtitleShadow1") as? SKLabelNode
        subTitleShadow1Label?.text = subTitleLabel?.text
        let subTitleShadow2Label = self.childNode(withName: "//SubtitleShadow2") as? SKLabelNode
        subTitleShadow2Label?.text = subTitleLabel?.text
        
        let buttonFont = gameLogic!.localizedString(forKey: "ButtonFontName", value: nil, table: "Story")
		buttonsNode = self.childNode(withName: "//Buttons")
		backgroundNode = self.childNode(withName: "//Background")
		pressNode = self.childNode(withName: "//Press") as? SKLabelNode
		playResumeNode = self.childNode(withName: "//PlayResume")
		fromTheTopNode = self.childNode(withName: "//FromTheTop")
		configNode = self.childNode(withName: "//Config")
		creditsNode = self.childNode(withName: "//Credits")
        let fromTheTopLabel = self.childNode(withName: "//FromTheTopLabel") as? SKLabelNode
        fromTheTopLabel?.text = gameLogic!.localizedString(forKey: "Restart", value: nil, table: "Story")
        fromTheTopLabel?.fontName = buttonFont
        let configLabel = self.childNode(withName: "//ConfigLabel") as? SKLabelNode
        configLabel?.text = gameLogic!.localizedString(forKey: "Setup", value: nil, table: "Story")
        configLabel?.fontName = buttonFont
        let creditsLabel = self.childNode(withName: "//CreditsLabel") as? SKLabelNode
        creditsLabel?.text = gameLogic!.localizedString(forKey: "Credits", value: nil, table: "Story")
        creditsLabel?.fontName = buttonFont
        pressNode?.text = gameLogic!.localizedString(forKey: "Press to continue...", value: nil, table: "Story")
		
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
        configCloseLabel?.text = gameLogic!.localizedString(forKey: "Close", value: nil, table: "Story")
        configCloseLabel?.fontName = buttonFont
		
		// Restart Popup
		restartPopupNode = self.childNode(withName: "//RestartPopup")
		yesNode = self.childNode(withName: "//Yes")
		noNode = self.childNode(withName: "//No")
        let yesLabel = self.childNode(withName: "//YesLabel") as? SKLabelNode
        yesLabel?.text = gameLogic!.localizedString(forKey: "Yes", value: nil, table: "Story")
        yesLabel?.fontName = buttonFont
        let noLabel = self.childNode(withName: "//NoLabel") as? SKLabelNode
        noLabel?.text = gameLogic!.localizedString(forKey: "No", value: nil, table: "Story")
        noLabel?.fontName = buttonFont
        let restartGameLabel = self.childNode(withName: "//RestartText1") as? SKLabelNode
        restartGameLabel?.text = gameLogic!.localizedString(forKey: "Restart the game!", value: nil, table: "Story")
        restartGameLabel?.fontName = buttonFont
        let restartGameShadow1Label = self.childNode(withName: "//RestartText1Shadow1") as? SKLabelNode
        restartGameShadow1Label?.text = restartGameLabel?.text
        restartGameShadow1Label?.fontName = buttonFont
        let restartGameShadow2Label = self.childNode(withName: "//RestartText1Shadow2") as? SKLabelNode
        restartGameShadow2Label?.text = restartGameLabel?.text
        restartGameShadow2Label?.fontName = buttonFont
        let areYouSureLabel = self.childNode(withName: "//RestartText2") as? SKLabelNode
        areYouSureLabel?.text = gameLogic!.localizedString(forKey: "Are you sure?", value: nil, table: "Story")
        areYouSureLabel?.fontName = buttonFont
        let areYouSureShadow1Label = self.childNode(withName: "//RestartText2Shadow1") as? SKLabelNode
        areYouSureShadow1Label?.text = areYouSureLabel?.text
        areYouSureShadow1Label?.fontName = buttonFont
        let areYouSureShadow2Label = self.childNode(withName: "//RestartText2Shadow2") as? SKLabelNode
        areYouSureShadow2Label?.text = areYouSureLabel?.text
        areYouSureShadow2Label?.fontName = buttonFont
		
        fromTheTopNode?.isHidden = self.gameLogic?.gameState.currentSceneIndex == -1 && self.gameLogic?.gameState.currentScript == nil
		let playResumeLabel = self.childNode(withName: "//PlayResumeLabel") as? SKLabelNode
		playResumeLabel!.text = fromTheTopNode!.isHidden ? gameLogic!.localizedString(forKey: "Play", value: nil, table: "Story") : gameLogic!.localizedString(forKey: "Continue", value: nil, table: "Story")
        playResumeLabel?.fontName = buttonFont
		
		configPopupNode?.isHidden = true
		debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
        debugModeLabel?.fontName = buttonFont
		#if DEBUG
			debugModeNode!.isHidden = false
		#else
			debugModeNode!.isHidden = true
		#endif
		puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? gameLogic!.localizedString(forKey: "Skip Puzzles is On", value: nil, table: "Story") : gameLogic!.localizedString(forKey: "Skip Puzzles is Off", value: nil, table: "Story")
        puzzleModeLabel?.fontName = buttonFont
		switch self.gameLogic!.textSpeed {
		case .Slow:
			textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Slow", value: nil, table: "Story")
			break
		case .Normal:
			textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Normal", value: nil, table: "Story")
			break
		case .Fast:
			textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Fast", value: nil, table: "Story")
			break
		}
        textSpeedLabel?.fontName = buttonFont
        volumeNode = self.childNode(withName: "//Volume")
        volumeLabel = self.childNode(withName: "//VolumeLabel") as? SKLabelNode
        if (volumeLabel != nil) {
            volumeLabel?.fontName = buttonFont
            switch self.gameLogic!.volumeLevel {
            case .Off:
                volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Off", value: nil, table: "Story")
                break
            case .Low:
                volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Low", value: nil, table: "Story")
                break
            case .Medium:
                volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Medium", value: nil, table: "Story")
                break
            case .High:
                volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: High", value: nil, table: "Story")
                break
            }
        }
        languageNode = self.childNode(withName: "//Language")
        languageLabel = self.childNode(withName: "//LanguageLabel") as? SKLabelNode
        if (languageLabel != nil) {
            languageLabel?.fontName = buttonFont
            languageLabel?.text = gameLogic!.localizedString(forKey: "Language: " + gameLogic!.languages[gameLogic!.currentLanguageIndex], value: nil, table: "Story")
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
		//pressNode?.run(SKAction(named: "PressToContinueFade")!)
		restartPopupNode?.isHidden = true
        selectedNode = playResumeNode
	}
	
    open func nextNode() {
        if (buttonsNode!.alpha >= 0.5 && configPopupNode!.isHidden) {
            selectedNode?.run(SKAction.scale(to: 0.75, duration: 0.3))
            if (selectedNode == fromTheTopNode) {
                selectedNode = playResumeNode
            } else if (selectedNode == playResumeNode) {
                selectedNode = configNode
            } else if (selectedNode == configNode) {
                selectedNode = creditsNode
            } else if (selectedNode == creditsNode) {
                if (fromTheTopNode?.isHidden ?? true) {
                    selectedNode = playResumeNode
                } else {
                    selectedNode = fromTheTopNode
                }
            }
            selectedNode?.run(SKAction.scale(to: 0.85, duration: 0.3))
        } else if (buttonsNode!.alpha >= 0.5) {
            if #available(tvOS 10.0, iOS 10.0, *) {
                selectedNode?.run(SKAction.scale(to: CGSize(width: 3, height: 0.8), duration: 0.3))
            } else {
                // Fallback on earlier versions
            }
            if (selectedNode == configCloseNode) {
                selectedNode = debugModeNode
            } else if (selectedNode == debugModeNode) {
                selectedNode = puzzleModeNode
            } else if (selectedNode == puzzleModeNode) {
                selectedNode = textSpeedNode
            } else if (selectedNode == textSpeedNode) {
                selectedNode = volumeNode
            } else if (selectedNode == volumeNode) {
                selectedNode = languageNode
            } else if (selectedNode == languageNode) {
                selectedNode = configCloseNode
            }
            if #available(tvOS 10.0, iOS 10.0, *) {
                selectedNode?.run(SKAction.scale(to: CGSize(width: 3.1, height: 0.9), duration: 0.3))
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    open func prevNode() {
        if (buttonsNode!.alpha >= 0.5 && configPopupNode!.isHidden) {
            selectedNode?.run(SKAction.scale(to: 0.75, duration: 0.3))
            if (selectedNode == fromTheTopNode) {
                selectedNode = creditsNode
            } else if (selectedNode == playResumeNode) {
                if (fromTheTopNode?.isHidden ?? true) {
                    selectedNode = creditsNode
                } else {
                    selectedNode = fromTheTopNode
                }
            } else if (selectedNode == configNode) {
                selectedNode = playResumeNode
            } else if (selectedNode == creditsNode) {
                selectedNode = configNode
            }
            selectedNode?.run(SKAction.scale(to: 0.85, duration: 0.3))
        } else if (buttonsNode!.alpha >= 0.5) {
            if #available(tvOS 10.0, iOS 10.0, *) {
                selectedNode?.run(SKAction.scale(to: CGSize(width: 3, height: 0.8), duration: 0.3))
            } else {
                // Fallback on earlier versions
            }
            if (selectedNode == configCloseNode) {
                selectedNode = languageNode
            } else if (selectedNode == debugModeNode) {
                selectedNode = configCloseNode
            } else if (selectedNode == puzzleModeNode) {
                selectedNode = debugModeNode
            } else if (selectedNode == textSpeedNode) {
                selectedNode = puzzleModeNode
            } else if (selectedNode == volumeNode) {
                selectedNode = textSpeedNode
            } else if (selectedNode == languageNode) {
                selectedNode = volumeNode
            }
            if #available(tvOS 10.0, iOS 10.0, *) {
                selectedNode?.run(SKAction.scale(to: CGSize(width: 3.1, height: 0.9), duration: 0.3))
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
	// atode: combine the GameMenu and MainMenuConfig into a coherant menu system.
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
        var currentSelectedNode: SKNode? = nil
        if (point.x == CGFloat.infinity && point.y == CGFloat.infinity) {
            currentSelectedNode = selectedNode
        }
		if (pressToContinue) {
			if (pressNode!.alpha > 0.0) {
				pressToContinue = false
				if (backgroundNode?.position.x != 0) {
                    backgroundNode?.run((gameLogic?.loadAction(actionName: "PressToContinue", forResource: "Default.MyActions"))!)
                    buttonsNode?.run((gameLogic?.loadAction(actionName: "LongFadeIn", forResource: "Default.MyActions"))!)
				} else {
					buttonsNode?.run(SKAction.fadeIn(withDuration: 1.0))
				}
				pressNode?.removeAllActions()
				pressNode?.run(SKAction.fadeOut(withDuration: 0.3))
			} else {
				pressNode?.run(SKAction.fadeIn(withDuration: 0.3))
			}
		} else if (!restartPopupNode!.isHidden) {
			if (yesNode!.frame.contains(point) || currentSelectedNode == yesNode) {
				self.gameLogic?.restart()
				restartPopupNode?.isHidden = true
				buttonsNode!.isHidden = true
			} else if (noNode!.frame.contains(point) || currentSelectedNode == noNode) {
				restartPopupNode?.isHidden = true
				buttonsNode!.isHidden = false
			}
		} else if (buttonsNode!.alpha >= 0.5 && configPopupNode!.isHidden) {
			if (playResumeNode!.frame.contains(point) || currentSelectedNode == playResumeNode) {
				self.gameLogic?.start()
			} else if (!fromTheTopNode!.isHidden && (fromTheTopNode!.frame.contains(point) || selectedNode == fromTheTopNode)) {
				restartPopupNode?.isHidden = false
				buttonsNode!.isHidden = true
			} else if (configNode!.frame.contains(point) || currentSelectedNode == configNode) {
				configPopupNode?.isHidden = false
			} else if (creditsNode!.frame.contains(point) || currentSelectedNode == creditsNode) {
				self.gameLogic?.rollCredits()
			}
		} else if (buttonsNode!.alpha >= 0.5) {
			if (configCloseNode!.frame.contains(point) || currentSelectedNode == configCloseNode) {
				configPopupNode?.isHidden = true
			} else if (debugModeNode!.frame.contains(point) || currentSelectedNode == debugModeNode) {
				self.gameLogic!.sceneDebug = !self.gameLogic!.sceneDebug
				self.gameLogic!.saveGlobalState()
				debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
			} else if (puzzleModeNode!.frame.contains(point) || currentSelectedNode == puzzleModeNode) {
				self.gameLogic!.skipPuzzles = !self.gameLogic!.skipPuzzles
				self.gameLogic!.saveGlobalState()
				puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? gameLogic!.localizedString(forKey: "Skip Puzzles is On", value: nil, table: "Story") : gameLogic!.localizedString(forKey: "Skip Puzzles is Off", value: nil, table: "Story")
			} else if (textSpeedNode!.frame.contains(point) || currentSelectedNode == textSpeedNode) {
				self.gameLogic!.nextTextSpeed()
				switch self.gameLogic!.textSpeed {
				case .Slow:
					textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Slow", value: nil, table: "Story")
					break
				case .Normal:
					textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Normal", value: nil, table: "Story")
					break
				case .Fast:
					textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Fast", value: nil, table: "Story")
					break
				}
			} else if (volumeNode!.frame.contains(point) || currentSelectedNode == volumeNode) {
                self.gameLogic!.nextVolumeLevel()
                switch self.gameLogic!.volumeLevel {
                case .Off:
                    volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Off", value: nil, table: "Story")
                    break
                case .Low:
                    volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Low", value: nil, table: "Story")
                    break
                case .Medium:
                    volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Medium", value: nil, table: "Story")
                    break
                case .High:
                    volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: High", value: nil, table: "Story")
                    break
                }
            } else if (languageNode!.frame.contains(point) || currentSelectedNode == languageNode) {
                self.gameLogic!.nextLanguage()
                languageLabel?.text = gameLogic!.localizedString(forKey: "Language: " + gameLogic!.languages[gameLogic!.currentLanguageIndex], value: nil, table: "Story")
                self.didMove(to: self.view!)
            }
		}
	}
	
	override open func interactionButton(_ button: GamePadButton, timestamp: TimeInterval) {
		if (button == GamePadButton.CROSS) {
			if (restartPopupNode!.isHidden == false) {
				restartPopupNode?.isHidden = true
				buttonsNode!.isHidden = false
                return
			} else if (configPopupNode!.isHidden == false) {
				configPopupNode!.isHidden = true
                return
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
                pressNode?.run((gameLogic?.loadAction(actionName: "PressToContinueFade", forResource: "Default.MyActions"))!)
                return
            }
#if os(OSX)
			if (view!.window!.styleMask.contains(NSWindow.StyleMask.fullScreen)) {
				view?.window?.toggleFullScreen(self)
			}
#endif
        } else if (button == GamePadButton.UP){
            prevNode()
        } else if (button == GamePadButton.DOWN) {
            nextNode()
        } else if (button == GamePadButton.CIRCLE) {
            interactionEnded(CGPoint(x: CGFloat.infinity, y: CGFloat.infinity), timestamp: timestamp)
        }
	}
	
	override func update(_ currentTime: TimeInterval) {
		if (!loaded) {
            fromTheTopNode?.isHidden = self.gameLogic?.gameState.currentSceneIndex == -1 && self.gameLogic?.gameState.currentScript == nil
			let playResumeLabel = self.childNode(withName: "//PlayResumeLabel") as? SKLabelNode
			//let playResumeLabelShadow = self.childNode(withName: "//PlayResumeLabelShadow") as? SKLabelNode
			playResumeLabel!.text = fromTheTopNode!.isHidden ? gameLogic!.localizedString(forKey: "Play", value: nil, table: "Story") : gameLogic!.localizedString(forKey: "Continue", value: nil, table: "Story")
			//playResumeLabelShadow!.text = playResumeLabel!.text
			debugModeLabel!.text = self.gameLogic!.sceneDebug ? "Debug Mode is On" : "Debug Mode is Off"
			puzzleModeLabel!.text = self.gameLogic!.skipPuzzles ? gameLogic!.localizedString(forKey: "Skip Puzzles is On", value: nil, table: "Story") : gameLogic!.localizedString(forKey: "Skip Puzzles is Off", value: nil, table: "Story")
			switch self.gameLogic!.textSpeed {
            case .Slow:
                textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Slow", value: nil, table: "Story")
                break
            case .Normal:
                textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Normal", value: nil, table: "Story")
                break
            case .Fast:
                textSpeedLabel!.text = gameLogic!.localizedString(forKey: "Text Speed: Fast", value: nil, table: "Story")
				break
			}
            if (volumeLabel != nil) {
                switch self.gameLogic!.volumeLevel {
                case .Off:
                    volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Off", value: nil, table: "Story")
                    break
                case .Low:
                    volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Low", value: nil, table: "Story")
                    break
                case .Medium:
                    volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: Medium", value: nil, table: "Story")
                    break
                case .High:
                    volumeLabel!.text = gameLogic!.localizedString(forKey: "Volume: High", value: nil, table: "Story")
                    break
                }
            }
            if (languageLabel != nil) {
                languageLabel?.text = gameLogic!.localizedString(forKey: "Language: " + gameLogic!.languages[gameLogic!.currentLanguageIndex], value: nil, table: "Story")
            }
			loaded = true
		}
	}
}
