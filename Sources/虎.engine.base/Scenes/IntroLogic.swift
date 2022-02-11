//
//  IntroState.swift
//  虎.engine.base iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import AVKit
import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class IntroLogic: GameScene {

	var loaded: Bool = false
	
	class func newScene(gameLogic: GameLogic) -> IntroLogic {
        guard let scene = IntroLogic(fileNamed: gameLogic.loadUrl(forResource: gameLogic.appendAspectSuffix("Default.Intro"), withExtension: ".sks", subdirectory: "Scenes/" + gameLogic.getAspectSuffix())!.path) else {
            print("Failed to load Intro.sks")
            abort()
        }

        scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic;
		
        return scene
    }
	
	override func didMove(to view: SKView) {
		loaded = false
	}
	
	override func didEvaluateActions() {
		let lastFade = scene!.childNode(withName: "//LastFade")
		if (!lastFade!.hasActions()) {
			gameLogic?.nextScene()
		}
	}
	
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
	}
	
	override func update(_ currentTime: TimeInterval) {
		let node = self.childNode(withName: "//ThirdFade")
		if (!loaded && node!.alpha > 0) {
			let file = gameLogic?.loadUrl(forResource: "Default.Music", withExtension: ".mp3", subdirectory: "Music")
			if (file != nil) {
				if (self.gameLogic!.player != nil) {
					self.gameLogic!.player?.stop()
					self.gameLogic!.player = nil
				}
					  
				if (self.gameLogic!.player == nil) {
					do {
						try self.gameLogic!.player = AVAudioPlayer(contentsOf: file!)
						self.gameLogic!.player?.numberOfLoops = 1
						self.gameLogic!.player?.play()
					} catch  {
					}
				}
			}
			loaded = true
		}
	}
}
