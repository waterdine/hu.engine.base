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
        let scene: IntroLogic = gameLogic.loadScene(scene: "Default.Intro", resourceBundle: "虎.engine.base", classType: IntroLogic.classForKeyedUnarchiver()) as! IntroLogic
        return scene
    }
	
	override func didMove(to view: SKView) {
		loaded = false
        let titleNode = scene!.childNode(withName: "//Title") as? SKLabelNode
        if #available(iOS 11.0, *) {
            let attributes: [NSAttributedString.Key : Any]? = (titleNode?.attributedText?.attributes(at: 0, effectiveRange: nil))
            titleNode?.attributedText = NSAttributedString(string: (gameLogic?.localizedString(forKey: "Title", value: nil, table: "Story"))!, attributes: attributes)
        } else {
            titleNode?.text = gameLogic?.localizedString(forKey: "Title", value: nil, table: "Story")
        }
        let subTitleNode = scene!.childNode(withName: "//Subtitle") as? SKLabelNode
        subTitleNode?.text = gameLogic?.localizedString(forKey: "Subtitle", value: nil, table: "Story")
        let publisherNode = scene!.childNode(withName: "//Publisher") as? SKLabelNode
        publisherNode?.text = gameLogic?.localizedString(forKey: "PublisherText", value: nil, table: "Story")
        let developerNode = scene!.childNode(withName: "//Developer") as? SKLabelNode
        developerNode?.text = gameLogic?.localizedString(forKey: "DeveloperText", value: nil, table: "Story")
        //let eProducerTitleNode = scene!.childNode(withName: "//EProducerTitle") as? SKLabelNode
        var eProducerNameNode = scene!.childNode(withName: "//EProducerName") as? SKLabelNode
        if (eProducerNameNode == nil) {
            eProducerNameNode = scene!.childNode(withName: "//EProducerName1") as? SKLabelNode
        }
        let eProducerCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Executive Producer" })?.name
        eProducerNameNode?.text = eProducerCredit
        //let producerTitleNode = scene!.childNode(withName: "//ProducerTitle") as? SKLabelNode
        let producerNameNode = scene!.childNode(withName: "//ProducerName") as? SKLabelNode
        var producerCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Produced By" })?.name
        if (producerCredit == nil) {
            producerCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Producer" })?.name
        }
        if (producerCredit == nil) {
            producerCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Executive Producer" })?.name
        }
        producerNameNode?.text = producerCredit
        let directorTitleNode = scene!.childNode(withName: "//DirectorTitle") as? SKLabelNode
        let directorNameNode = scene!.childNode(withName: "//DirectorName") as? SKLabelNode
        var directorCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Written and Directed By" })?.name
        if (directorCredit == nil) {
            directorCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Writter and Director" })?.name
        }
        if (directorCredit == nil) {
            directorTitleNode?.text = "Created By"
            directorCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Creator" })?.name
            if (directorCredit == nil) {
                directorCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Created By" })?.name
            }
        }
        if (directorCredit == nil) {
            directorTitleNode?.text = "Directed By"
            directorCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Director" })?.name
            if (directorCredit == nil) {
                directorCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Directed By" })?.name
            }
        }
        if (directorCredit == nil) {
            directorTitleNode?.text = "Written By"
            directorCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Writer" })?.name
            if (directorCredit == nil) {
                directorCredit = gameLogic?.story?.Credits.first(where: { $0.title.trimmingCharacters(in: [":"]) == "Written By" })?.name
            }
        }
        directorNameNode?.text = directorCredit
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
            let file = gameLogic?.loadUrl(forResource: "Default.Music", resourceBundle: "", withExtension: ".mp3", subdirectory: "Music")
			if (file != nil) {
				if (self.gameLogic!.player != nil) {
					self.gameLogic!.player?.stop()
					self.gameLogic!.player = nil
				}
					  
				if (self.gameLogic!.player == nil) {
					do {
						try self.gameLogic!.player = AVAudioPlayer(contentsOf: file!)
						self.gameLogic!.player?.numberOfLoops = 1
                        self.gameLogic?.alignVolumeLevel()
						self.gameLogic!.player?.play()
					} catch  {
					}
				}
			}
			loaded = true
		}
	}
}
