//
//  File.swift
//  
//
//  Created by Sen on 05/01/2022.
//

import Foundation

open class BaseSceneSerialiser {
    public init() {
    }
    
    open func decode(from scriptParameters: [String : String], sceneType: String, strings: inout [String : String]) -> BaseScene? {
        return nil
    }
    
    open func decode(from decoder: Decoder, sceneType: String) throws -> BaseScene? {
        return nil
    }
    
    open func encode(to encoder: Encoder, scene: BaseScene) throws {
    }
    
    open func update(scene: BaseScene) -> BaseScene? {
        return nil
    }
    
    open func getDescription(scene: BaseScene) -> String? {
        return nil
    }
    
    open func appendText(scene: BaseScene, text: String, textBucket: String, chapterNumber: String, sceneNumber: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
    }
    
    open func stringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        return []
    }

    open func resolveSkipToIndexes(scene: BaseScene, indexMap: [Int : Int]) {
    }
}

open class GameSceneListSerialiser : BaseSceneSerialiser
{
    public override init() {
        super.init()
    }

    open override func decode(from scriptParameters: [String : String], sceneType: String, strings: inout [String : String]) -> BaseScene? {
        var scene: BaseScene? = nil
        switch sceneType {
            case "Intro":
                scene = IntroScene.init(from: scriptParameters, strings: &strings)
                break
            case "SkipTo":
                scene = SkipToScene.init(from: scriptParameters, strings: &strings)
                break
            default:
                break
        }
        return scene
    }

    open override func decode(from decoder: Decoder, sceneType: String) throws -> BaseScene? {
        var scene: BaseScene? = nil
        switch sceneType {
        case "Intro":
            scene = try IntroScene.init(from: decoder)
            break
        case "SkipTo":
            scene = try SkipToScene.init(from: decoder)
            break
        default:
            break
        }
        return scene
    }

    open override func encode(to encoder: Encoder, scene: BaseScene) throws {
        switch scene.Scene {
        case "Intro":
            try (scene as! IntroScene).encode(to: encoder)
            break
        case "SkipTo":
            try (scene as! SkipToScene).encode(to: encoder)
            break
        default:
            break
        }
    }

    open override func update(scene: BaseScene) -> BaseScene? {
        var newData: BaseScene? = nil
        switch scene.Scene {
        case "Intro":
            if (!(scene is IntroScene)) {
                newData = IntroScene()
            }
            break
        case "SkipTo":
            if (!(scene is SkipToScene)) {
                newData = SkipToScene()
            }
            break
        default:
            break
        }
        return newData
    }
        
    open override func getDescription(scene: BaseScene) -> String {
        switch scene.Scene {
            case "Intro":
                return (scene as! IntroScene).getDescription()
            case "SkipTo":
                return (scene as! SkipToScene).getDescription()
            default:
                return ""
        }
    }
    
    open override func appendText(scene: BaseScene, text: String, textBucket: String, chapterNumber: String, sceneNumber: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
    }
    
    open override func stringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        var lines: [String] = []
        switch scene.Scene {
            case "Intro":
                lines.append(contentsOf: (scene as! IntroScene).toStringsLines(index: index, strings: strings))
                break
            case "SkipTo":
                lines.append(contentsOf: (scene as! SkipToScene).toStringsLines(index: index, strings: strings))
                break
            default:
                break
        }
        return lines
    }
    
    open override func resolveSkipToIndexes(scene: BaseScene, indexMap: [Int : Int]) {
        switch scene.Scene {
        case "SkipTo":
            if (indexMap[(scene as! SkipToScene).SkipTo] != nil) {
                (scene as! SkipToScene).SkipTo = indexMap[(scene as! SkipToScene).SkipTo]!
            }
            break
        default:
            break
        }
    }
}

public func RegisterGameSceneInitialisers(sceneListSerialiser: inout SceneListSerialiser) {
    sceneListSerialiser.serialisers.append(GameSceneListSerialiser())
}