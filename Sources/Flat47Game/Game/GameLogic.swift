//
//  GameLogic.swift
//  SpriteKitTest
//
//  Created by x414e54 on 11/02/2021.
//

import AVKit
import SpriteKit

public enum TextSpeed: Int {
	case Slow, Normal, Fast
}

@available(iOS 10.0, *)
open class GameLogic: NSObject {
	
	var sceneTypes: NSDictionary
	var transition: ((GameScene, SKTransition?) -> Void)?
	
	// current storyline (saveable)
	open var currentSceneIndex: Int?
	open var currentChapterIndex: Int?
	open var flags: [String] = []
	open var variables: [String:String] = [:]
	open var textDelay: Double = 1.0
	open var textFadeTime: Double = 0.075
	open var actionDelay: Double = 0.5
	open var usedSquares: [Int] = []
	
	open var sceneDebug: Bool = false
	open var skipPuzzles: Bool = false
	open var player: AVAudioPlayer?
	open var fadePlayer: AVAudioPlayer?
	open var loopSound: AVAudioPlayer?
	open var currentScene: GameScene?
	open var tempCutScene: GameScene?
	
	open var textSpeed: TextSpeed = TextSpeed.Normal
	
	public class func newGame(transitionCallback: ((GameScene, SKTransition?) -> Void)?) -> GameLogic {
		let gameLogic = GameLogic()

		// TODO this probably does not need to be instances, could just be state struct + a static class.
		gameLogic.sceneTypes["MainMenuLogic"] = MainMenuLogic.newScene(gameLogic: gameLogic)
		gameLogic.sceneTypes["IntroLogic"] = IntroLogic.newScene(gameLogic: gameLogic)
		gameLogic.sceneTypes["CreditsLogic"] = CreditsLogic.newScene(gameLogic: gameLogic)
		
		//gameLogic.tempCutScene = CutSceneLogic.newScene(gameLogic: gameLogic)
		gameLogic.transition = transitionCallback
		gameLogic.currentSceneIndex = -1;
		gameLogic.currentChapterIndex = 0;
		gameLogic.transitionToScene(forceTransition: nil)
		gameLogic.loadState()
		gameLogic.alignTextSpeed()
		return gameLogic
	}
	
	func loadMusic(musicFile: String?, transitionType: String?, sceneData: NSDictionary?) {
		if (musicFile != nil) {
			do {
				if (musicFile! != "") {
					let file = Bundle.main.url(forResource: musicFile!, withExtension: ".mp3")
					if (file != nil) {
						let restartMusic: Bool? = sceneData?["RestartMusic"] as? Bool
						let fadeMusic: Bool = (transitionType != nil && (transitionType! == "Fade" || transitionType! == "CrossFade" || transitionType! == "Flash"))
						if (player != nil && (player!.url != file || (restartMusic != nil && restartMusic! == true))) {
							if (fadeMusic) {
								if (fadePlayer != nil) {
									fadePlayer?.stop()
								}
								fadePlayer = player
								fadePlayer?.setVolume(0, fadeDuration: 1.0)
							} else {
								player?.stop()
							}
							player = nil
						} else if (fadePlayer != nil) {
							fadePlayer?.stop()
							fadePlayer = nil
						}
						
						if (player == nil) {
							try player = AVAudioPlayer(contentsOf: file!)
							player?.numberOfLoops = -1
							player?.play()
						}
					} else {
						if (player != nil) {
							player?.stop()
							player = nil
						}
					}
				} else {
					if (player != nil) {
						player?.stop()
						player = nil
					}
				}
			} catch  {
			}
		}
	}

	open func transitionToScene(forceTransition: SKTransition?)
	{
		self.variables["LondonTime"] = "13:20"
		self.variables["LondonWeather"] = "cloudy"
		
		let chapterListPlist = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Story", ofType: "plist")!)
		let chapterList: NSArray? = chapterListPlist?["Chapters"] as? NSArray
		
		var sceneList: NSArray? = nil
		var sceneTypeName = "MainMenu"
		var sceneData: NSDictionary? = nil
		
		var reloadSceneData = true
		while (reloadSceneData) {
			reloadSceneData = false
			
			if (chapterList != nil && chapterList!.count > self.currentChapterIndex! && self.currentChapterIndex! >= 0) {
				let chapterFileName = chapterList?[self.currentChapterIndex!] as? String
				let sceneListPlist = NSDictionary(contentsOfFile: Bundle.main.path(forResource: chapterFileName, ofType: "plist")!)
				sceneList = sceneListPlist?["Scenes"] as? NSArray
			}
			
			if (sceneList != nil && sceneList!.count > self.currentSceneIndex! && self.currentSceneIndex! >= 0) {
				sceneData = sceneList?[self.currentSceneIndex!] as? NSDictionary
				sceneTypeName = sceneData!["Scene"] as! String
			} else if (sceneList != nil && self.currentSceneIndex! >= sceneList!.count) {
				self.currentSceneIndex! = 0
				self.currentChapterIndex! += 1
				saveState()
				reloadSceneData = true
			}
		}
		
		var musicFile: String? = sceneData?["Music"] as? String
		
		var transition: SKTransition? = forceTransition
		var scene: GameScene? = nil
		var sceneType = sceneTypes[sceneTypeName]
		if (sceneType == nil) {
			sceneType = UnknownLogic.newScene(gameLogic: gameLogic)
		}
		
		// TODO tidy this up!
		if (sceneType.requiresMusic && musicFile == nil) {
			musicFile = "Main"
		}
		if (sceneType.defaultTransition) {
			transition = SKTransition.fade(withDuration: 1.0)
		}
		if (sceneType.allowSkipCredits) {
			credits.skipable = false
		}
		if (sceneType.customLogic()) {
			return
		}
		
		// TODO Convert to NSDictionary to make extendable as well.
		var rotateScene = false
		let transitionType: String? = ((sceneData?["Transition"] as? String?)!)
		if (transition == nil && transitionType != nil) {
			switch transitionType {
			case "Fade":
				transition = SKTransition.fade(withDuration: 1.0)
				rotateScene = true
				break
			case "LongFade":
				transition = SKTransition.fade(withDuration: 3.0)
				rotateScene = true
				break
			case "Flash":
				transition = SKTransition.fade(with: UIColor.white, duration: 1.0)
				rotateScene = true
				break
			case "FadeBlack":
				transition = SKTransition.fade(with: UIColor.black, duration: 3.0)
				rotateScene = true
				break
			case "CrossFade":
				transition = SKTransition.crossFade(withDuration: 1.0)
				break
			case "ForceUp":
				transition = SKTransition.push(with: SKTransitionDirection.up, duration: 0.25)
				rotateScene = true
				break
			case "ForceRight":
				transition = SKTransition.push(with: SKTransitionDirection.right, duration: 0.25)
				rotateScene = true
				break
			case "ForceDown":
				transition = SKTransition.moveIn(with:  SKTransitionDirection.up, duration: 0.25)
				rotateScene = true
				break
			case "Open":
				transition = SKTransition.doorway(withDuration: 1.0)
			case "Close":
				transition =  SKTransition.doorsCloseHorizontal(withDuration: 1.0)
				break
			default:
				break
			}
		}
		
		if (rotateScene) {
			if (scene == self.sceneTypes[4] || scene == tempCutScene) {
				let temp = self.sceneTypes[4]
				self.sceneTypes[4] = tempCutScene!
				tempCutScene = temp
				scene = self.sceneTypes[4]
			}
		}

		loadMusic(musicFile: musicFile, transitionType: transitionType, sceneData: sceneData)
		
		scene!.data = sceneData
		self.transition?(scene!, transition)
		currentScene = scene
	}
	
	open func saveState()
	{
		UserDefaults.standard.setValue(self.currentSceneIndex, forKey: "currentSceneIndex")
		UserDefaults.standard.setValue(self.currentChapterIndex, forKey: "currentChapterIndex")
		UserDefaults.standard.setValue(self.flags, forKey: "flags")
		UserDefaults.standard.setValue(self.textSpeed.rawValue, forKey: "textSpeed")
		UserDefaults.standard.setValue(self.sceneDebug, forKey: "sceneDebug")
		UserDefaults.standard.setValue(self.skipPuzzles, forKey: "skipPuzzles")
		UserDefaults.standard.setValue(self.variables, forKey: "variables")
	}
	
	open func loadState()
	{
		let savedCurrentSceneIndex: Int? = UserDefaults.standard.value(forKey: "currentSceneIndex") as? Int
		let savedCurrentChapterIndex: Int? = UserDefaults.standard.value(forKey: "currentChapterIndex") as? Int
		let savedFlags: [String]? = UserDefaults.standard.value(forKey: "flags") as? [String]
		let savedVariables: [String:String]? = UserDefaults.standard.value(forKey: "variables") as? [String:String]
		let savedTextSpeed: Int? = UserDefaults.standard.value(forKey: "textSpeed") as? Int
		let savedSceneDebug: Bool? = UserDefaults.standard.value(forKey: "sceneDebug") as? Bool
		let savedSkipPuzzles: Bool? = UserDefaults.standard.value(forKey: "skipPuzzles") as? Bool
		
		if (savedCurrentSceneIndex != nil) {
			self.currentSceneIndex = savedCurrentSceneIndex! - 1
		}
		if (savedCurrentChapterIndex != nil) {
			self.currentChapterIndex = savedCurrentChapterIndex!
		}
		if (savedFlags != nil) {
			self.flags = savedFlags!
		}
		if (savedVariables != nil) {
			self.variables = savedVariables!
		}
		if (savedTextSpeed != nil) {
			switch savedTextSpeed! {
			case TextSpeed.Slow.rawValue:
				self.textSpeed = .Slow
				break
			case TextSpeed.Normal.rawValue:
				self.textSpeed = .Normal
				break
			case TextSpeed.Fast.rawValue:
				self.textSpeed = .Fast
				break
			default:
				self.textSpeed = .Normal
			}
		}
		if (savedSceneDebug != nil) {
			self.sceneDebug = savedSceneDebug!
		}
		if (savedSkipPuzzles != nil) {
			self.skipPuzzles = savedSkipPuzzles!
		}
	}
	
	open func setScene(index: Int)
	{
		self.currentSceneIndex! = index
		saveState()
		transitionToScene(forceTransition: nil)
	}
	
	open func nextScene() {
		self.currentSceneIndex! += 1
		saveState()
		transitionToScene(forceTransition: nil)
	}
	
	func prevScene() {
		self.currentSceneIndex! -= 1
		saveState()
		transitionToScene(forceTransition: nil)
	}

	open func start() {
		self.currentSceneIndex! += 1
		saveState()
		transitionToScene(forceTransition: SKTransition.fade(withDuration: 1.0))
	}
	
	open func restart() {
		self.currentSceneIndex! = 0
		self.currentChapterIndex! = 0
		self.flags = []
		self.variables = [:]
		saveState()
		transitionToScene(forceTransition: SKTransition.fade(withDuration: 1.0))
	}
	
	open func rollCredits() {
		let credits = self.sceneTypes[10] as! CreditsLogic
		credits.skipable = true
		self.transition?(self.sceneTypes[10], SKTransition.fade(withDuration: 1.0))
		currentScene = self.sceneTypes[10]
	}
	
	open func backToMenu() {
		loadMusic(musicFile: "Main", transitionType: nil, sceneData: nil)
		self.transition?(self.sceneTypes[1], SKTransition.fade(withDuration: 1.0))
		currentScene = self.sceneTypes[1]
		loadState()
	}
	
	open func gameOver() {
		self.transition?(self.sceneTypes[6], SKTransition.fade(withDuration: 1.0))
		currentScene = self.sceneTypes[6]
	}
	
	func alignTextSpeed() {
		switch textSpeed {
		case .Slow:
			textDelay = 1.0
			textFadeTime = 0.2
			break
		case .Normal:
			textDelay = 1.0
			textFadeTime = 0.075
			break
		case .Fast:
			textDelay = 0.5
			textFadeTime = 0.01
			break
		}
	}
		
	open func nextTextSpeed() {
		switch textSpeed {
		case .Slow:
			textSpeed = .Normal
			break
		case .Normal:
			textSpeed = .Fast
			break
		case .Fast:
			textSpeed = .Slow
			break
		}
		saveState()
		alignTextSpeed()
	}
	
	open func getAspectSuffix() -> String {
#if os(OSX)
		let aspect = Int((NSScreen.main?.frame.width)! / (NSScreen.main?.frame.height)! * 10)
#else
		let aspect = Int(UIScreen.main.bounds.width / UIScreen.main.bounds.height * 10)
#endif
		switch aspect {
		case 4:
			return "_Odd"
		case 21:
			return "_Odd"
		case 6:
			return "_Old"
		case 15:
			return "_Old"
		case 7:
			return "_iPad"
		case 13:
			return "_iPad"
		case 17:
			return "_AppleTV"
		default: // case 5
			return ""
		}
	}
	
	open func getChapterTable() -> String {
		let chapterListPlist = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Story", ofType: "plist")!)
		let chapterList: NSArray? = chapterListPlist?["Chapters"] as? NSArray
		
		if (chapterList != nil && chapterList!.count > self.currentChapterIndex! && self.currentChapterIndex! >= 0)
		{
			return chapterList![self.currentChapterIndex!] as! String
		}
		return "Story"
	}
	
	open func unwrapVariables(text: String) -> String {
		var returnText = text
		if (returnText.contains("$")) {
			for variable in variables {
				returnText = returnText.replacingOccurrences(of: "$" + variable.key, with: variable.value)
			}
		}
		return returnText
	}
}
