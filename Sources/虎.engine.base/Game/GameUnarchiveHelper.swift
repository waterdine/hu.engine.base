//
//  File.swift
//  
//
//  Created by ito.antonia on 13/02/2022.
//

import SpriteKit

@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class GameKeyedUnarchiver : NSKeyedUnarchiver {
    public var gameLogic: GameLogic? = nil
    public var enableTextureReplacement = false
    init(forReadingWith: Data, gameLogic: GameLogic) {
        self.gameLogic = gameLogic
        super.init(forReadingWith: forReadingWith)
    }
    
    open override func decodeObject(forKey key: String) -> Any? {
        if (enableTextureReplacement && (key.contains("texture") || key.contains("Texture"))) {
            let gameTexture: GameTexture? = super.decodeObject(forKey: key) as! GameTexture?
            if (gameTexture != nil) {
                return SKTexture(imageNamed: gameTexture!.imagePath!)
            } else {
                return nil
            }
        } else {
            return super.decodeObject(forKey: key)
        }
    }
}

@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class GameTexture : SKTexture {
    var imagePath: String? = nil
    
    public required init?(coder aDecoder: NSCoder) {
        let imageName: String? = aDecoder.decodeObject(forKey: "_imgName") as! String? // Used an archiver on SKTexture to list all keys.
        let gameLogic = (aDecoder as! GameKeyedUnarchiver).gameLogic
        imagePath = gameLogic?.loadUrl(forResource: "Default." + imageName!, withExtension: ".png", subdirectory: "Images")?.path.replacingOccurrences(of: " ", with: "\\")
        
        if (imagePath == nil) {
            imagePath = gameLogic?.loadUrl(forResource: "Default." + imageName!, withExtension: ".png", subdirectory: "Images/Backgrounds")?.path.replacingOccurrences(of: " ", with: "\\")
        }
        
        if (imagePath == nil) {
            print("Unable to find: \(imageName!)")
            imagePath = imageName
        }
        super.init()
    }
}

@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class GameSpriteNode: SKSpriteNode {
    public required init?(coder aDecoder: NSCoder) {
        (aDecoder as! GameKeyedUnarchiver).enableTextureReplacement = true
        super.init(coder: aDecoder)
        (aDecoder as! GameKeyedUnarchiver).enableTextureReplacement = false
    }
}
