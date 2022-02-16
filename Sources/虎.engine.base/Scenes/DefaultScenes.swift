//
//  DefaultScenes.swift
//  Shared
//
//  Created by ito.antonia on 28/07/2021.
//

import Foundation

// Base Data Types

public enum ActorAction: String, Codable {
    case None, EnterLeft, EnterRight, Jump
}

public enum TextEvent: String, Codable {
    case None, Instant
}

public struct Library: Identifiable, Codable {
    public var id: UUID = UUID()
    public var name: String = ""
    public var version: Int = 0
    public var frameworkVersion: Int = 0
    public var encrypted: Bool = false
    
    public init() {
    }
}

public struct Product: Identifiable, Codable {
    public var id: UUID = UUID()
    public var name: String = ""
    public var version: Int = 0
    public var frameworkVersion: Int = 0
    public var encrypted: Bool = false
    public var defaultLibrary: String = ""
    public var libraries: [String] = []
    
    public init() {
    }
}

public struct Chapter: Identifiable, Codable {
    public var id: UUID = UUID()
    public var name: String = ""
    public var sutra: String = ""
    
    public init() {
    }
}

public class Story: Identifiable, Codable {
    public var id: UUID = UUID()
    public var Version: Int? = nil
    public var Chapters: [Chapter] = []
    
    enum BaseSceneCodingKeys: String, CodingKey {
        case id
        case Version
        case Chapters
    }
    
    public init() {
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseSceneCodingKeys.self)
        Version = try container.decodeIfPresent(Int.self, forKey: BaseSceneCodingKeys.Version)
        if (Version == nil || Version! == 0) {
            Version = 0
            let chapters: [String] = try container.decodeIfPresent([String].self, forKey: BaseSceneCodingKeys.Chapters)!
            for chapter in chapters {
                var newChapter: Chapter = Chapter()
                newChapter.name = chapter
                Chapters.append(newChapter)
            }
        } else if (Version! > 0) {
            Chapters = try container.decodeIfPresent([Chapter].self, forKey: BaseSceneCodingKeys.Chapters)!
        }
        //id = try container.decode(UUID.self, forKey: BaseSceneCodingKeys.id)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BaseSceneCodingKeys.self)
        //try container.encode(id, forKey: BaseSceneCodingKeys.id)
        if (Version == nil || Version! == 0) {
            Version = 0
            var chapters: [String] = []
            for chapter in Chapters {
                chapters.append(chapter.name)
            }
            try container.encode(chapters, forKey: BaseSceneCodingKeys.Chapters)
        } else if (Version! > 0) {
            try container.encode(Version, forKey: BaseSceneCodingKeys.Version)
            try container.encode(Chapters, forKey: BaseSceneCodingKeys.Chapters)
        }
    }
}

/*public struct Actor: Identifiable, Codable {
    public var id: UUID = UUID()
    public var name: String
}*/

open class TextLine: Identifiable, Codable {
    public var id: UUID = UUID()
    public var actor: String = ""
    public var actorAction: ActorAction = ActorAction.None
    public var textString: String = ""
    public var textEvent: TextEvent = TextEvent.None
    
    public init() {
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        textString = try container.decode(String.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        //try container.encode(id, forKey: BaseSceneCodingKeys.id)
        //try container.encode(label, forKey: BaseSceneCodingKeys.label)
        try container.encode(textString)
    }
}

open class BaseScene: Identifiable, Codable {
    public var id: UUID = UUID()
    public var Scene: String = "Unknown"
    public var Label: String? = nil
    
    enum BaseSceneCodingKeys: String, CodingKey {
        case id
        case Scene
        case Label
    }
    
    public init() {
    }
    
    public init(from scriptParameters: [String : String], strings: inout [String : String]) {
        if (scriptParameters["Scene"] != nil) {
            Scene = scriptParameters["Scene"]!
        }

        if (scriptParameters["Label"] != nil && !scriptParameters["Label"]!.isEmpty) {
            Label = scriptParameters["Label"]!
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseSceneCodingKeys.self)
        Scene = try container.decode(String.self, forKey: BaseSceneCodingKeys.Scene)
        Label = try container.decodeIfPresent(String.self, forKey: BaseSceneCodingKeys.Label)
        //id = try container.decode(UUID.self, forKey: BaseSceneCodingKeys.id)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BaseSceneCodingKeys.self)
        //try container.encode(id, forKey: BaseSceneCodingKeys.id)
        try container.encodeIfPresent(Label, forKey: BaseSceneCodingKeys.Label)
        try container.encode(Scene, forKey: BaseSceneCodingKeys.Scene)
    }
    
    open func getDescription() -> String{
        return Scene
    }
    
    open func toStringsHeader(index: Int, strings: [String : String]) -> String {
        return "// Scene \(index) - " + Scene
    }
    
    open func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        return "// Scene \(index) - " + Scene
    }
    
    open func toStringsLines(index: Int, strings: [String : String]) -> [String] {
        return (Label != nil) ? ["// Label: " + Label!, toStringsHeader(index: index, strings: strings)] : [toStringsHeader(index: index, strings: strings)]
    }
    
    open func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        return (Label != nil) ? ["// Label: " + Label!, toScriptHeader(index: index, strings: strings, indexMap: indexMap)] : [toScriptHeader(index: index, strings: strings, indexMap: indexMap)]
    }
}

open class IntroScene: BaseScene {
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

open class VisualScene: BaseScene {
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

open class CreditsScene: VisualScene {
    //enum CreditsCodingKeys: String, CodingKey {
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

open class SkipToScene: BaseScene {
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
