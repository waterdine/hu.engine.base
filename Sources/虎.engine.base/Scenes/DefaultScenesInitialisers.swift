//
//  DefaultScenesInitialisers.swift
//  
//
//  Created by ito.antonia on 05/01/2022.
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
    
    open func appendText(scene: BaseScene, text: String, textBucket: String, scriptNumber: String, sceneNumber: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
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
            case "SkipBack":
                scene = SkipBackScene.init(from: scriptParameters, strings: &strings)
                break
            case "Credits":
                scene = CreditsScene.init(from: scriptParameters, strings: &strings)
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
        case "SkipBack":
            scene = try SkipBackScene.init(from: decoder)
            break
        case "Credits":
            scene = try CreditsScene.init(from: decoder)
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
        case "SkipBack":
            try (scene as! SkipBackScene).encode(to: encoder)
            break
        case "Credits":
            try (scene as! CreditsScene).encode(to: encoder)
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
        case "SkipBack":
            if (!(scene is SkipBackScene)) {
                newData = SkipBackScene()
            }
            break
        case "Credits":
            if (!(scene is CreditsScene)) {
                newData = CreditsScene()
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
            case "SkipBack":
                return (scene as! SkipBackScene).getDescription()
            case "Credits":
                return (scene as! CreditsScene).getDescription()
            default:
                return ""
        }
    }
    
    open override func appendText(scene: BaseScene, text: String, textBucket: String, scriptNumber: String, sceneNumber: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
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
            case "SkipBack":
                lines.append(contentsOf: (scene as! SkipBackScene).toStringsLines(index: index, strings: strings))
                break
            case "Credits":
                lines.append(contentsOf: (scene as! CreditsScene).toStringsLines(index: index, strings: strings))
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

public func RegisterGameScenes(gameLogic: GameLogic) {
    gameLogic.sceneTypes["MainMenu"] = MainMenuLogic.newScene(gameLogic: gameLogic)
    gameLogic.sceneTypes["Intro"] = IntroLogic.newScene(gameLogic: gameLogic)
    gameLogic.sceneTypes["SkipTo"] = SkipToLogic.newScene(gameLogic: gameLogic)
    gameLogic.sceneTypes["Credits"] = CreditsLogic.newScene(gameLogic: gameLogic)
}

public func RegisterGameSceneInitialisers(sceneListSerialiser: inout SceneListSerialiser) {
    sceneListSerialiser.serialisers.append(GameSceneListSerialiser())
}

public func LoadGameModuleResourceBundle(bundles: inout [String:Bundle]) {
    bundles["虎.engine.base"] = Bundle.init(url: Bundle.main.resourceURL!.appendingPathComponent("虎.engine.base_虎.engine.base.bundle"))!
}

public func RegisterGameSettings(settings: inout [String])
{
    settings.append("Title");
    settings.append("Subtitle");
    settings.append("FontName");
    //settings.append("FontScale");
    settings.append("ButtonFontName");
    //settings.append("CharacterFontName");
    //settings.append("CharacterFontScale");
    //settings.append("EncodeFontScale");
    settings.append("DeveloperText");
    settings.append("PublisherText");
}

public func RegisterGameTranslatableStrings(strings: inout [String])
{
    strings.append("Play");
    strings.append("Continue");
    strings.append("Restart");
    strings.append("Setup");
    strings.append("Credits");
    strings.append("Main Menu");
    strings.append("Close");
    strings.append("Yes");
    strings.append("No");
    strings.append("Restart the game!");
    strings.append("Are you sure?");
    strings.append("Skip Puzzles is Off");
    strings.append("Skip Puzzles is On");
    strings.append("Text Speed: Slow");
    strings.append("Text Speed: Normal");
    strings.append("Text Speed: Fast");
    strings.append("Volume: Off");
    strings.append("Volume: Low");
    strings.append("Volume: Medium");
    strings.append("Volume: High");
    strings.append("Press to continue...");
    strings.append("Language: Name");
}
