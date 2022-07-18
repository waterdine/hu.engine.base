//
//  GameState.swift
//  
//
//  Created by ito.antonia on 07/03/2022.
//

import Foundation

public struct SceneFlow: Codable {
    var sceneIndex: Int
    var script: String
}

public class GameState: Codable {
    var version: Int = 0
    open var currentSceneIndex: Int? = nil
    open var currentScript: String? = nil
    //open var log: [ChoiceFlow]
    open var sceneStack: [SceneFlow] = []
    open var flags: [String] = []
    open var variables: [String:String] = [:]
    
    enum GameStateCodingKeys: String, CodingKey {
        case Version
        case CurrentSceneIndex
        case CurrentScript
        case SceneStack
        case Flags
        case Variables
    }
    
    public init() {
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GameStateCodingKeys.self)
        version = try container.decode(Int.self, forKey: GameStateCodingKeys.Version)
        currentSceneIndex = try container.decodeIfPresent(Int.self, forKey: GameStateCodingKeys.CurrentSceneIndex)
        currentScript = try container.decodeIfPresent(String.self, forKey: GameStateCodingKeys.CurrentScript)
        sceneStack = try container.decode([SceneFlow].self, forKey: GameStateCodingKeys.SceneStack)
        flags = try container.decode([String].self, forKey: GameStateCodingKeys.Flags)
        variables = try container.decode([String:String].self, forKey: GameStateCodingKeys.Variables)
    }
    
    open func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GameStateCodingKeys.self)
        try container.encode(version, forKey: GameStateCodingKeys.Version)
        try container.encodeIfPresent(currentSceneIndex, forKey: GameStateCodingKeys.CurrentSceneIndex)
        try container.encodeIfPresent(currentScript, forKey: GameStateCodingKeys.CurrentScript)
        try container.encode(sceneStack, forKey: GameStateCodingKeys.SceneStack)
        try container.encode(flags, forKey: GameStateCodingKeys.Flags)
        try container.encode(variables, forKey: GameStateCodingKeys.Variables)
    }
}
