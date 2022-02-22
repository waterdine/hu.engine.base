//
//  File.swift
//  
//
//  Created by ito.antonia on 13/02/2022.
//

import SpriteKit
import AVKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class GameKeyedUnarchiver : NSKeyedUnarchiver {
    public var gameLogic: GameLogic? = nil
    init(forReadingWith: Data, gameLogic: GameLogic) {
        self.gameLogic = gameLogic
        super.init(forReadingWith: forReadingWith)
    }
    
    open override func decodeObject(forKey key: String) -> Any? {
        print(key)
        if (key.contains("_imgName")) {
            let imageName: String? = super.decodeObject(forKey: key) as! String?
            var imagePath = gameLogic?.loadUrl(forResource: "Default." + imageName!, withExtension: ".png", subdirectory: "Images")?.path
            
            if (imagePath == nil) {
                imagePath = gameLogic?.loadUrl(forResource: "Default." + imageName!, withExtension: ".png", subdirectory: "Images/Backgrounds")?.path
            }
            
            if (imagePath == nil) {
                print("Unable to find: \(imageName!)")
                imagePath = imageName
            }
            return imagePath
        } else if (key.contains("_fileName")) {
            let fileName: String? = super.decodeObject(forKey: key) as! String?
            var fileURL = gameLogic?.loadUrl(forResource: "Default." + fileName!, withExtension: ".mp3", subdirectory: "Sound")
            
            if (fileURL == nil) {
                fileURL = gameLogic?.loadUrl(forResource: "Default." + fileName!, withExtension: ".mp3", subdirectory: "Music")
            }
            
            if (fileURL == nil) {
                print("Unable to find: \(fileName!)")
            }
            return fileURL
        } else if (key.contains("_actions")) {
            var actionsArray = super.decodeObject(forKey: "_actions") as? [SKAction]
            if (actionsArray != nil) {
                for index in actionsArray!.indices {
                    let currentAction = actionsArray![index]
                    if (currentAction is GamePlaySound) {
                        let fileUrl = (currentAction as! GamePlaySound).fileUrl
                        actionsArray![index] = SKAction.run({[fileUrl] in
                            if (self.gameLogic?.loopSound != nil) {
                                self.gameLogic?.loopSound?.stop()
                            }
                            if (fileUrl != nil) {
                                try! self.gameLogic?.loopSound = AVAudioPlayer(contentsOf: fileUrl!)
                                self.gameLogic?.loopSound?.numberOfLoops = -1
                                self.gameLogic?.loopSound?.play()
                            }
                        })
                    }
                }
            }
            return actionsArray
        } else {
            return super.decodeObject(forKey: key)
        }
    }
}

@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class GamePlaySound : SKAction {
    var fileUrl: URL? = nil
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        fileUrl = aDecoder.decodeObject(forKey: "_fileName") as! URL?
    }
}
