//
//  File.swift
//  
//
//  Created by Sen on 05/01/2022.
//

import Foundation

open class BaseSceneInitialiser {
    enum BaseSceneCodingKeys: String, CodingKey {
        case id
        case Scene
        case Label
    }
    
    public func create(from scriptParameters: [String : String], strings: inout [String : String]) -> BaseScene {
        let newScene: BaseScene = BaseScene()
        if (scriptParameters["Scene"] != nil) {
            newScene.Scene = scriptParameters["Scene"]!
        }

        if (scriptParameters["Label"] != nil && !scriptParameters["Label"]!.isEmpty) {
            newScene.Label = scriptParameters["Label"]!
        }
    }
    
    public func decode(from decoder: Decoder) throws -> BaseScene  {
        let newScene: BaseScene = BaseScene()
        let container = try decoder.container(keyedBy: BaseSceneCodingKeys.self)
        newScene.Scene = try container.decode(String.self, forKey: BaseSceneCodingKeys.Scene)
        newScene.Label = try container.decodeIfPresent(String.self, forKey: BaseSceneCodingKeys.Label)
        //id = try container.decode(UUID.self, forKey: BaseSceneCodingKeys.id)
    }
    
    open func encode(to encoder: Encoder, scene: BaseScene) throws {
        var container = encoder.container(keyedBy: BaseSceneCodingKeys.self)
        //try container.encode(id, forKey: BaseSceneCodingKeys.id)
        try container.encodeIfPresent(scene.Label, forKey: BaseSceneCodingKeys.Label)
        try container.encode(scene.Scene, forKey: BaseSceneCodingKeys.Scene)
    }
    
    open func getDescription(scene: BaseScene) -> String{
        return scene.Scene
    }
    
    open func toStringsHeader(scene: BaseScene, index: Int, strings: [String : String]) -> String {
        return "// Scene \(index) - " + scene.Scene
    }
    
    open func toScriptHeader(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        return "// Scene \(index) - " + scene.Scene
    }
    
    open func toStringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        return (scene.Label != nil) ? ["// Label: " + scene.Label!, toStringsHeader(index: index, strings: strings)] : [toStringsHeader(index: index, strings: strings)]
    }
    
    open func toScriptLines(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        return (scene.Label != nil) ? ["// Label: " + scene.Label!, toScriptHeader(index: index, strings: strings, indexMap: indexMap)] : [toScriptHeader(index: index, strings: strings, indexMap: indexMap)]
    }
}

open class IntroSceneInitialiser: BaseSceneInitialiser {
    //enum IntroCodingKeys: String, CodingKey {
    //}
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}

open class VisualSceneInitialiser: BaseSceneInitialiser {
    public var Music: String? = nil
    public var RestartMusic: Bool? = nil
    public var Transition: String? = nil
    
    enum VisualSceneCodingKeys: String, CodingKey {
        case Music
        case RestartMusic
        case Transition
    }
    
    public override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
        
        if (scriptParameters["Music"] != nil) {
            Music = scriptParameters["Music"]
        }
        
        if (scriptParameters["RestartMusic"] != nil) {
            RestartMusic = (scriptParameters["RestartMusic"] == "True") ? true : false
        }
        
        if (scriptParameters["Transition"] != nil) {
            Transition = scriptParameters["Transition"]
        }
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: VisualSceneCodingKeys.self)
        Music = try container.decodeIfPresent(String.self, forKey: VisualSceneCodingKeys.Music)
        RestartMusic = try container.decodeIfPresent(Bool.self, forKey: VisualSceneCodingKeys.RestartMusic)
        Transition = try container.decodeIfPresent(String.self, forKey: VisualSceneCodingKeys.Transition)
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VisualSceneCodingKeys.self)
        try container.encodeIfPresent(Music, forKey: VisualSceneCodingKeys.Music)
        try container.encodeIfPresent(RestartMusic, forKey: VisualSceneCodingKeys.RestartMusic)
        try container.encodeIfPresent(Transition, forKey: VisualSceneCodingKeys.Transition)
    }
    
    open override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
        
        if (Music != nil) {
            scriptLine += ", Music: " + Music!
        }
        
        if (RestartMusic != nil) {
            scriptLine += ", RestartMusic: " + ((RestartMusic! == true) ? "True" : "False")
        }
        
        if (Transition != nil) {
            scriptLine += ", Transition: " + Transition!
        }
        
        return scriptLine
    }
}

open class SkipToSceneInitialiser: BaseSceneInitialiser {
    public var SkipTo: Int = 0
    public var Flag: String? = nil
    
    enum SkipToCodingKeys: String, CodingKey {
        case SkipTo
        case Flag
    }
    
    public override init() {
        super.init()
    }
    
    public override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
        
        if (scriptParameters["SkipTo"] != nil) {
            SkipTo = Int(scriptParameters["SkipTo"]!)!
        }
        
        if (scriptParameters["Flag"] != nil) {
            Flag = scriptParameters["Flag"]!
        }
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: SkipToCodingKeys.self)
        SkipTo = try container.decode(Int.self, forKey: SkipToCodingKeys.SkipTo)
        Flag = try container.decodeIfPresent(String.self, forKey: SkipToCodingKeys.Flag)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: SkipToCodingKeys.self)
        try container.encode(SkipTo, forKey: SkipToCodingKeys.SkipTo)
        try container.encodeIfPresent(Flag, forKey: SkipToCodingKeys.Flag)
    }
    
    open override func getDescription() -> String{
        return "SkipTo, \(SkipTo)"
    }
    
    open override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
        
        if (indexMap[SkipTo] != nil) {
            scriptLine += ", SkipTo: \(indexMap[SkipTo]!)"
        } else {
            scriptLine += ", SkipTo: \(SkipTo)"
        }
        
        if (Flag != nil) {
            scriptLine += ", Flag: " + Flag!
        }
        
        return scriptLine
    }
}

public func RegisterGameSceneInitialisers(parser: SceneParser) {
    parser.sceneInitialisers["Intro"] = IntroSceneInitialiser()
    parser.sceneInitialisers["SkipTo"] = SkipToSceneInitialiser()
