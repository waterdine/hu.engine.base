//
//  GameLogic.swift
//  SpriteKitTest
//
//  Created by ito.antonia on 11/02/2021.
//

import AVKit
import SpriteKit
//import CryptoKit

func masterKey() -> Data {
    return Data(base64Encoded: "6Vs77pau68MPuZaLWv/msQ==")! // "Hey, hey, hey, hey, ho, ho, ho, ho, da fun da, da fun da."
}

public enum TextSpeed: Int {
	case Slow, Normal, Fast
}

public enum VolumeLevel: Int {
    case Off, Low, Medium, High
}

@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class GameLogic: NSObject {
	
    open var baseDir: URL? = nil
	open var sceneTypes: [String:GameScene] = [:]
	open var transition: ((GameScene, SKTransition?) -> Void)?
    open var sceneListSerialiser: SceneListSerialiser = SceneListSerialiser()
	
	// current storyline (saveable)
	open var currentSceneIndex: Int?
	open var currentChapterIndex: Int?
    open var sceneLabels: [String:Int] = [:]
	open var flags: [String] = []
	open var variables: [String:String] = [:]
	open var textDelay: Double = 1.0
	open var textFadeTime: Double = 0.075
	open var actionDelay: Double = 0.5
	open var usedSquares: [Int] = []
    open var story: Story? = nil
    open var strings: [String:[String:String]]? = nil
	
	open var sceneDebug: Bool = false
	open var skipPuzzles: Bool = false
	open var player: AVAudioPlayer?
	open var fadePlayer: AVAudioPlayer?
	open var loopSound: AVAudioPlayer?
	open var currentScene: GameScene?
	open var tempCutScene: GameScene?
    open var lives: Int?
    //open var playerHealth: Vitamins, etc.
	
	open var textSpeed: TextSpeed = TextSpeed.Normal
    open var volumeLevel: VolumeLevel = VolumeLevel.Medium
	
    public class func newGame(transitionCallback: ((GameScene, SKTransition?) -> Void)?, baseDir: URL?, stringsOverride: [String:[String:String]]?) -> GameLogic {
		let gameLogic = GameLogic()

		// atode: this probably does not need to be instances, could just be state struct + a static class.
		gameLogic.sceneTypes["MainMenu"] = MainMenuLogic.newScene(gameLogic: gameLogic)
		gameLogic.sceneTypes["Intro"] = IntroLogic.newScene(gameLogic: gameLogic)
		gameLogic.sceneTypes["SkipTo"] = SkipToLogic.newScene(gameLogic: gameLogic)
		gameLogic.sceneTypes["Credits"] = CreditsLogic.newScene(gameLogic: gameLogic)

        RegisterGameSceneInitialisers(sceneListSerialiser: &gameLogic.sceneListSerialiser)
		
		//gameLogic.tempCutScene = CutSceneLogic.newScene(gameLogic: gameLogic)
		gameLogic.transition = transitionCallback
        gameLogic.baseDir = baseDir
        gameLogic.strings = stringsOverride
		gameLogic.currentSceneIndex = -1;
		gameLogic.currentChapterIndex = 0;
		gameLogic.transitionToScene(forceTransition: nil)
		gameLogic.loadState()
		gameLogic.alignTextSpeed()
        gameLogic.alignVolumeLevel()
		return gameLogic
	}
	
	func loadMusic(musicFile: String?, transitionType: String?, sceneData: VisualScene?) {
		if (musicFile != nil) {
			do {
				if (musicFile! != "") {
					let file = Bundle.main.url(forResource: musicFile!, withExtension: ".mp3")
					if (file != nil) {
                        let restartMusic: Bool? = sceneData?.RestartMusic
						let fadeMusic: Bool = (transitionType != nil && (transitionType! == "Fade" || transitionType! == "CrossFade" || transitionType! == "Flash"))
						if (player != nil && (player!.url != file || (restartMusic != nil && restartMusic! == true))) {
							if (fadeMusic) {
								if (fadePlayer != nil) {
									fadePlayer?.stop()
								}
								fadePlayer = player
                                if #available(iOS 10.0, *) {
                                    fadePlayer?.setVolume(0, fadeDuration: 1.0)
                                } else {
                                    fadePlayer?.volume = 0;
                                }
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
                            alignVolumeLevel()
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

	open func transitionToScene(forceTransition: SKTransition?) {
		// atode: REMOVVE!!
		self.variables["LondonTime"] = "13:20"
		self.variables["LondonWeather"] = "cloudy"
        
        //let chapterList: NSArray? = chapterListPlist?["Chapters"] as? NSArray

        let chaptersPlistURL = baseDir != nil ? baseDir!.appendingPathComponent("Story").appendingPathExtension("plist") : Bundle.main.url(forResource: "Story", withExtension: "plist")!
        let chaptersPlistContents = try! Data(contentsOf: chaptersPlistURL)
        let chaptersPlistString: String? = String(data: chaptersPlistContents, encoding: .utf8)
        if (chaptersPlistString != nil && chaptersPlistString!.starts(with: "<?xml")) {
            /*let chapterListPlist = try! PropertyListDecoder().decode([String : [String]].self, from: chaptersPlistContents)
            let chapterList: [String] = chapterListPlist["Chapters"]! as [String]
            story = Story()
            story?.Version = 0
            story?.Chapters = []
            for chapter in chapterList {
                var newChapter: Chapter = Chapter()
                newChapter.sutra = ""
                newChapter.name = chapter
                story!.Chapters.append(newChapter)
            }*/
            story = try! PropertyListDecoder().decode(Story.self, from: chaptersPlistContents)
        /*} else {
            if #available(iOS 13.0, *) {
                let sealedBox = try! AES.GCM.SealedBox.init(combined: chaptersPlistContents)
                let key = SymmetricKey.init(data: masterKey())
                let data = try! AES.GCM.open(sealedBox, using: key)
                story = try! PropertyListDecoder().decode(Story.self, from: data)
            }*/
        } else {
            story = try! PropertyListDecoder().decode(Story.self, from: chaptersPlistContents)
        }
		
		var sceneList: Scenes? = nil
		var sceneTypeName = "MainMenu"
		var sceneData: BaseScene? = nil
		
		var reloadSceneData = true
		while (reloadSceneData) {
			reloadSceneData = false
			
			if (story != nil && story!.Chapters.count > self.currentChapterIndex! && self.currentChapterIndex! >= 0) {
                let chapterFileName = story!.Chapters[self.currentChapterIndex!].name
                let sceneListPlistURL = baseDir != nil ? baseDir!.appendingPathComponent(chapterFileName).appendingPathComponent(chapterFileName).appendingPathExtension("plist") : Bundle.main.url(forResource: chapterFileName, withExtension: "plist")
                let sceneListContents = try! Data(contentsOf: sceneListPlistURL!)
                let sceneListString: String? = String(data: sceneListContents, encoding: .utf8)
                let decoder: PropertyListDecoder = PropertyListDecoder()
                decoder.userInfo[SceneListSerialiser().userInfoKey!] = sceneListSerialiser
                if (sceneListString != nil && sceneListString!.starts(with: "<?xml")) {
                    sceneList = try! decoder.decode(Scenes.self, from: sceneListContents)
                /*} else {
                    if #available(iOS 13.0, *) {
                        let sealedBox = try! AES.GCM.SealedBox.init(combined: chaptersPlistContents)
                        let key = SymmetricKey.init(data: masterKey())
                        let data = try! AES.GCM.open(sealedBox, using: key)
                        sceneList = try! PropertyListDecoder().decode(Scenes.self, from: data)
                    }*/
                } else {
                    sceneList = try! decoder.decode(Scenes.self, from: sceneListContents)
                }
                
                // loop sceneList to find sceneLabels and add to dictionary, as index.
                //sceneLabels[name] = index
                sceneLabels.removeAll()
                /*for <#item#> in <#items#> {
                    if (sceneName != nil) {
                        sceneNames[sceneName] =
                    }
                }*/
			} else if (story != nil && self.currentChapterIndex! >= story!.Chapters.count) {
				self.currentSceneIndex! = 0
				self.currentChapterIndex! = 0
				self.flags = []
				self.variables = [:]
				saveState()
				self.currentSceneIndex! = -1
			}
			
            if (sceneList != nil && sceneList!.Scenes.count > self.currentSceneIndex! && self.currentSceneIndex! >= 0) {
                sceneData = sceneList!.Scenes[self.currentSceneIndex!].data
                sceneTypeName = sceneData!.Scene
			} else if (sceneList != nil && self.currentSceneIndex! >= sceneList!.Scenes.count) {
				self.currentSceneIndex! = 0
				self.currentChapterIndex! += 1
				saveState()
				reloadSceneData = true
			}
		}
		
        var musicFile: String? = (sceneData as? VisualScene)?.Music
		
		var transition: SKTransition? = forceTransition
		var scene: GameScene? = sceneTypes[sceneTypeName]
		if (scene == nil) {
			scene = UnknownLogic.newScene(gameLogic: self)
		}

		if (scene!.requiresMusic && musicFile == nil) {
			musicFile = scene!.defaultMusicFile
		}
		
		if (scene!.defaultTransition) {
			transition = SKTransition.fade(withDuration: 1.0)
		}
		
		let credits = scene as? CreditsLogic
		if (credits != nil) {
			credits!.skipable = scene!.allowSkipCredits
		}
		
		// atode: Convert to NSDictionary to make extendable as well.
		var rotateScene = false
        let transitionType: String? = (sceneData as? VisualScene)?.Transition
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
				rotateScene = true
			case "Close":
				transition =  SKTransition.doorsCloseHorizontal(withDuration: 1.0)
				rotateScene = true
				break
			default:
				break
			}
		}
		
		if (rotateScene) {
			if (scene == self.sceneTypes["CutScene"] || scene == self.sceneTypes["TempCutScene"]) {
				if (currentScene == self.sceneTypes["TempCutScene"]) {
					scene = self.sceneTypes["CutScene"]
				} else {
					scene = self.sceneTypes["TempCutScene"]
				}
			}
		}

		loadMusic(musicFile: musicFile, transitionType: transitionType, sceneData: (sceneData as? VisualScene))
		
		scene!.data = sceneData
		if (scene!.customLogic()) {
			return
		}
		self.transition?(scene!, transition)
		currentScene = scene
	}
	
	open func saveState() {
		UserDefaults.standard.setValue(max(0, self.currentSceneIndex!), forKey: "currentSceneIndex")
		UserDefaults.standard.setValue(max(0, self.currentChapterIndex!), forKey: "currentChapterIndex")
		UserDefaults.standard.setValue(self.flags, forKey: "flags")
		UserDefaults.standard.setValue(self.textSpeed.rawValue, forKey: "textSpeed")
		UserDefaults.standard.setValue(self.sceneDebug, forKey: "sceneDebug")
		UserDefaults.standard.setValue(self.skipPuzzles, forKey: "skipPuzzles")
		UserDefaults.standard.setValue(self.variables, forKey: "variables")
        UserDefaults.standard.setValue(self.volumeLevel.rawValue, forKey: "volumeLevel")
	}
	
	open func loadState() {
		let savedCurrentSceneIndex: Int? = UserDefaults.standard.value(forKey: "currentSceneIndex") as? Int
		let savedCurrentChapterIndex: Int? = UserDefaults.standard.value(forKey: "currentChapterIndex") as? Int
		let savedFlags: [String]? = UserDefaults.standard.value(forKey: "flags") as? [String]
		let savedVariables: [String:String]? = UserDefaults.standard.value(forKey: "variables") as? [String:String]
		let savedTextSpeed: Int? = UserDefaults.standard.value(forKey: "textSpeed") as? Int
        let savedVolume: Int? = UserDefaults.standard.value(forKey: "volumeLevel") as? Int
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
        if (savedVolume != nil) {
            switch savedVolume! {
            case VolumeLevel.Off.rawValue:
                self.volumeLevel = .Off
                break
            case VolumeLevel.Low.rawValue:
                self.volumeLevel = .Low
                break
            case VolumeLevel.Medium.rawValue:
                self.volumeLevel = .Medium
                break
            case VolumeLevel.High.rawValue:
                self.volumeLevel = .High
                break
            default:
                self.volumeLevel = .Medium
            }
        }
		if (savedSceneDebug != nil) {
			self.sceneDebug = savedSceneDebug!
		}
		if (savedSkipPuzzles != nil) {
			self.skipPuzzles = savedSkipPuzzles!
		}
	}
	
    open func setScene(sceneIndex: Int, chapterIndex: Int)
	{
		self.currentSceneIndex! = sceneIndex
        self.currentChapterIndex!= chapterIndex
		saveState()
		transitionToScene(forceTransition: nil)
	}
	
	open func nextScene() {
		self.currentSceneIndex! += 1
		saveState()
		transitionToScene(forceTransition: nil)
	}
	
	open func prevScene() {
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
		let credits = self.sceneTypes["Credits"] as! CreditsLogic
		credits.skipable = true
		self.transition?(self.sceneTypes["Credits"]!, SKTransition.fade(withDuration: 1.0))
		currentScene = self.sceneTypes["Credits"]
	}
	
	open func backToMenu() {
		loadMusic(musicFile: "Main", transitionType: nil, sceneData: nil)
		self.transition?(self.sceneTypes["MainMenu"]!, SKTransition.fade(withDuration: 1.0))
		currentScene = self.sceneTypes["MainMenu"]
		loadState()
	}
	
	open func gameOver() {
		self.transition?(self.sceneTypes["GameOver"]!, SKTransition.fade(withDuration: 1.0))
		currentScene = self.sceneTypes["GameOver"]
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
    
    func alignVolumeLevel() {
        switch volumeLevel {
        case .Off:
            if #available(iOS 10.0, *) {
                player?.setVolume(0.0, fadeDuration: 0.0)
            } else {
                player?.volume = 0.0
            }
            break
        case .Low:
            if #available(iOS 10.0, *) {
                player?.setVolume(0.1, fadeDuration: 0.0)
            } else {
                player?.volume = 0.1
            }
            break
        case .Medium:
            if #available(iOS 10.0, *) {
                player?.setVolume(0.5, fadeDuration: 0.0)
            } else {
                player?.volume = 0.5
            }
            break
        case .High:
            if #available(iOS 10.0, *) {
                player?.setVolume(1.0, fadeDuration: 0.0)
            } else {
                player?.volume = 1.0
            }
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
    
    open func nextVolumeLevel() {
        switch volumeLevel {
        case .Off:
            volumeLevel = .Low
            break
        case .Low:
            volumeLevel = .Medium
            break
        case .Medium:
            volumeLevel = .High
            break
        case .High:
            volumeLevel = .Off
            break
        }
        saveState()
        alignVolumeLevel()
    }
    
	open func getAspectSuffix() -> String {
#if os(OSX)
		//let aspect = Int((NSScreen.main?.frame.width)! / (NSScreen.main?.frame.height)! * 10)
		return "_AppleTV"
#else
		let aspect = Int(UIScreen.main.bounds.width / UIScreen.main.bounds.height * 10)

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
#endif
	}
	
	open func getScaleMode() -> SKSceneScaleMode {
#if os(OSX)
		return .aspectFit
#else
		return .aspectFill
#endif
	}
	
	open func getChapterTable() -> String {
        if (story != nil && story!.Chapters.count > self.currentChapterIndex! && self.currentChapterIndex! >= 0)
		{
            return story!.Chapters[self.currentChapterIndex!].name
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
    
    open func getProperty() -> String {
        if (story != nil && story!.Chapters.count > self.currentChapterIndex! && self.currentChapterIndex! >= 0)
        {
            return story!.Chapters[self.currentChapterIndex!].name
        }
        return "Story"
    }
    
    open func localizedString(forKey: String, value: String?, table: String) -> String
    {
        if (strings != nil) {
            return strings![table]![forKey]!
        } else {
            return Bundle.main.localizedString(forKey: forKey, value: value, table: table)
        }
    }
}
