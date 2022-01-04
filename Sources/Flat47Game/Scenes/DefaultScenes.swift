//
//  DefaultScenes.swift
//  Shared
//
//  Created by A. A. Bills on 28/07/2021.
//

import Foundation

// Base Data Types

enum CharacterAction: String, Codable {
    case None, EnterLeft, EnterRight, Jump
}

enum TextEvent: String, Codable {
    case None, Instant
}

struct Product: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var version: Int = 0
    var frameworkVersion: Int = 0
}

struct Chapter: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var sutra: String = ""
}

class Story: Identifiable, Codable {
    var id: UUID = UUID()
    var Version: Int? = nil
    var Chapters: [Chapter] = []
    
    enum BaseSceneCodingKeys: String, CodingKey {
        case id
        case Version
        case Chapters
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
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

struct Character: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
}

class TextLine: Identifiable, Codable {
    var id: UUID = UUID()
    var character: String = ""
    var characterAction: CharacterAction = CharacterAction.None
    var textString: String = ""
    var textEvent: TextEvent = TextEvent.None
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        textString = try container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        //try container.encode(id, forKey: BaseSceneCodingKeys.id)
        //try container.encode(label, forKey: BaseSceneCodingKeys.label)
        try container.encode(textString)
    }
}

class BaseScene: Identifiable, Codable {
    var id: UUID = UUID()
    var Scene: String = "Unknown"
    var Label: String? = nil
    
    enum BaseSceneCodingKeys: String, CodingKey {
        case id
        case Scene
        case Label
    }
    
    init() {
    }
    
    init(from scriptParameters: [String : String], strings: inout [String : String]) {
        if (scriptParameters["Scene"] != nil) {
            Scene = scriptParameters["Scene"]!
        }

        if (scriptParameters["Label"] != nil && !scriptParameters["Label"]!.isEmpty) {
            Label = scriptParameters["Label"]!
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseSceneCodingKeys.self)
        Scene = try container.decode(String.self, forKey: BaseSceneCodingKeys.Scene)
        Label = try container.decodeIfPresent(String.self, forKey: BaseSceneCodingKeys.Label)
        //id = try container.decode(UUID.self, forKey: BaseSceneCodingKeys.id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BaseSceneCodingKeys.self)
        //try container.encode(id, forKey: BaseSceneCodingKeys.id)
        try container.encodeIfPresent(Label, forKey: BaseSceneCodingKeys.Label)
        try container.encode(Scene, forKey: BaseSceneCodingKeys.Scene)
    }
    
    func getDescription() -> String{
        return Scene
    }
    
    func toStringsHeader(index: Int, strings: [String : String]) -> String {
        return "// Scene \(index) - " + Scene
    }
    
    func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        return "// Scene \(index) - " + Scene
    }
    
    func toStringsLines(index: Int, strings: [String : String]) -> [String] {
        return (Label != nil) ? ["// Label: " + Label!, toStringsHeader(index: index, strings: strings)] : [toStringsHeader(index: index, strings: strings)]
    }
    
    func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        return (Label != nil) ? ["// Label: " + Label!, toScriptHeader(index: index, strings: strings, indexMap: indexMap)] : [toScriptHeader(index: index, strings: strings, indexMap: indexMap)]
    }
}

class IntroScene: BaseScene {
    //enum IntroCodingKeys: String, CodingKey {
    //}
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}

class VisualScene: BaseScene {
    var Music: String? = nil
    var RestartMusic: Bool? = nil
    var Transition: String? = nil
    
    enum VisualSceneCodingKeys: String, CodingKey {
        case Music
        case RestartMusic
        case Transition
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
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
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: VisualSceneCodingKeys.self)
        Music = try container.decodeIfPresent(String.self, forKey: VisualSceneCodingKeys.Music)
        RestartMusic = try container.decodeIfPresent(Bool.self, forKey: VisualSceneCodingKeys.RestartMusic)
        Transition = try container.decodeIfPresent(String.self, forKey: VisualSceneCodingKeys.Transition)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: VisualSceneCodingKeys.self)
        try container.encodeIfPresent(Music, forKey: VisualSceneCodingKeys.Music)
        try container.encodeIfPresent(RestartMusic, forKey: VisualSceneCodingKeys.RestartMusic)
        try container.encodeIfPresent(Transition, forKey: VisualSceneCodingKeys.Transition)
    }
    
    override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
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
