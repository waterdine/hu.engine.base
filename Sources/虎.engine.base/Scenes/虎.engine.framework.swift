//
//  虎.engine.framework.swift
//  Shared
//
//  Created by ito.antonia on 28/07/2021.
//

import SpriteKit

public let FRAMEWORK_VERSION = 0

public struct SceneListSerialiser
{
    public let userInfoKey = CodingUserInfoKey.init(rawValue: "SceneListSerialiser")
    
    public var serialisers: [BaseSceneSerialiser] = []
    public init() {
        
    }
}

public class SceneWrapper: Identifiable, Codable {
    public var id: UUID = UUID()
    public var data: BaseScene = BaseScene()
    
    enum SceneKeys: String, CodingKey {
        case Scene
    }
    
    public init() {
        
    }
    
    public init(sceneListSerialiser: SceneListSerialiser, scriptLine: String, label: String, strings: inout [String : String], scriptString: String, sceneString: inout String, sceneLabelMap: inout [String : Int]) {
        let scriptLineSplit = scriptLine.split(separator: ",")
        let sceneTypeSplit = scriptLineSplit[0].split(separator: "-")
        let sceneType: String = String(sceneTypeSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":"])
        var parameters: [String : String] = ["Scene" : sceneType]
        for parameterCombined in scriptLineSplit {
            if (!parameterCombined.starts(with: "// Scene")) {
                let parameterSplit = parameterCombined.split(separator: ":")
                let parameter = String(parameterSplit[0]).trimmingCharacters(in: [" ", "-", ",", ":"])
                let value = String(parameterSplit[1]).trimmingCharacters(in: [" ", ",", ":"])
                parameters[parameter] = value
            }
        }
        
        parameters["Chapter"] = scriptString
        parameters["SceneNumber"] = sceneString
        parameters["Label"] = label
        
        // Map the SkipTos to SceneLabels
        if (parameters["SkipTo"] != nil) {
            var newSkipTo = ""
            for skipToUntrimmed in parameters["SkipTo"]!.split(separator: ";") {
                let skipToTrimmed = skipToUntrimmed.trimmingCharacters(in: [" ", ",", ";"])
                var skipToNumber = Int(skipToTrimmed)
                if (skipToNumber == nil) {
                    if (sceneLabelMap[skipToTrimmed] == nil) {
                        let newIndex = -(sceneLabelMap.count + 1)
                        sceneLabelMap[skipToTrimmed] = newIndex
                        skipToNumber = newIndex
                    } else {
                        skipToNumber = sceneLabelMap[skipToTrimmed]!
                    }
                }
                
                if (!newSkipTo.isEmpty) {
                    newSkipTo += ";"
                }
                
                newSkipTo += "\(skipToNumber!)"
            }
            parameters["SkipTo"] = newSkipTo
        }
        
        for serialiser in sceneListSerialiser.serialisers {
            let newData = serialiser.decode(from: parameters, sceneType: sceneType, strings: &strings)
            if (newData != nil) {
                data = newData!
            }
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SceneKeys.self)
        let scene = try container.decodeIfPresent(String.self, forKey: SceneKeys.Scene) ?? "Unknown"
        for serialiser in (decoder.userInfo[SceneListSerialiser().userInfoKey!] as! SceneListSerialiser).serialisers {
            let newData = try serialiser.decode(from: decoder, sceneType: scene)
            if (newData != nil) {
                data = newData!
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        for serialiser in (encoder.userInfo[SceneListSerialiser().userInfoKey!] as! SceneListSerialiser).serialisers {
            try! serialiser.encode(to: encoder, scene: data)
        }
    }
    
    public func update(sceneListSerialiser: SceneListSerialiser)
    {
        var newData: BaseScene = data
        for serialiser in sceneListSerialiser.serialisers {
            newData = serialiser.update(scene: newData)!
        }
        newData.Scene = data.Scene
        newData.Label = data.Label
        data = newData
    }
    
    public func getDescription(sceneListSerialiser: SceneListSerialiser) -> String {
        var description = ""
        for serialiser in sceneListSerialiser.serialisers {
            if (description.isEmpty) {
                description = serialiser.getDescription(scene: data) ?? ""
            }
        }
        return description
    }
    
    public func appendText(sceneListSerialiser: SceneListSerialiser, text: String, textBucket: String, script: String, scene: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
        for serialiser in sceneListSerialiser.serialisers {
            serialiser.appendText(scene: data, text: text, textBucket: textBucket, scriptNumber: script, sceneNumber: scene, lineIndex: lineIndex, strings: &strings, command: command, sceneLabelMap: &sceneLabelMap)
        }
    }
    
    public func stringsLines(sceneListSerialiser: SceneListSerialiser, index: Int, strings: [String : String]) -> [String] {
        var stringsLines: [String] = []
        
        for serialiser in sceneListSerialiser.serialisers {
            stringsLines.append(contentsOf: serialiser.stringsLines(scene: data, index: index, strings: strings))
        }
        return stringsLines
    }

    public func resolveSkipToIndexes(sceneListSerialiser: SceneListSerialiser, indexMap: [Int : Int]) {
        for serialiser in sceneListSerialiser.serialisers {
            serialiser.resolveSkipToIndexes(scene: data, indexMap: indexMap)
        }
    }
}

public class Scenes: Codable {
    public var CreatedBy: String = ""
    public var Created: Date = Date()
    public var Scenes: [SceneWrapper] = []
    
    enum BaseSceneCodingKeys: String, CodingKey {
        case id
        case CreatedBy
        case Created
        case Scenes
    }
    
    public init() {
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BaseSceneCodingKeys.self)
        CreatedBy = try container.decodeIfPresent(String.self, forKey: BaseSceneCodingKeys.CreatedBy) ?? ""
        Created = try container.decodeIfPresent(Date.self, forKey: BaseSceneCodingKeys.Created) ?? Date()
        Scenes = try container.decodeIfPresent([SceneWrapper].self, forKey: BaseSceneCodingKeys.Scenes) ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: BaseSceneCodingKeys.self)
        //try container.encode(id, forKey: BaseSceneCodingKeys.id)
        try container.encode(CreatedBy, forKey: BaseSceneCodingKeys.CreatedBy)
        try container.encode(Created, forKey: BaseSceneCodingKeys.Created)
        try container.encode(Scenes, forKey: BaseSceneCodingKeys.Scenes)
    }
}
