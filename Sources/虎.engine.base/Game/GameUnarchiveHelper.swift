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
       if (key.contains("texture") || key.contains("Texture")) {
           let gameTexture: GameTexture? = super.decodeObject(forKey: key) as! GameTexture?
           if (gameTexture != nil) {
               return SKTexture(imageNamed: gameTexture!.fileUrl?.path ?? "")
           } else {
               return nil
           }
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
open class GameTexture : SKTexture {
    var fileUrl: URL? = nil
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        let fileName: String? = aDecoder.decodeObject(forKey: "_imgName") as! String?
        let gameLogic = (aDecoder as! GameKeyedUnarchiver).gameLogic
        fileUrl = gameLogic?.loadUrl(forResource: "Default." + fileName!, withExtension: ".png", subdirectory: "Images")
        
        if (fileUrl == nil) {
            fileUrl = gameLogic?.loadUrl(forResource: "Default." + fileName!, withExtension: ".png", subdirectory: "Images/Backgrounds")
        }
        
        if (fileUrl == nil) {
            print("Unable to find: \(fileName!)")
        }
    }
}


@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class GamePlaySound : SKAction {
    var fileUrl: URL? = nil
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        let fileName: String? = aDecoder.decodeObject(forKey: "_fileName") as! String?
        let gameLogic = (aDecoder as! GameKeyedUnarchiver).gameLogic
        fileUrl = gameLogic?.loadUrl(forResource: "Default." + fileName!, withExtension: ".mp3", subdirectory: "Sound")
        
        if (fileUrl == nil) {
            fileUrl = gameLogic?.loadUrl(forResource: "Default." + fileName!, withExtension: ".mp3", subdirectory: "Music")
        }
        
        if (fileUrl == nil) {
            print("Unable to find: \(fileName!)")
        }
    }
}
