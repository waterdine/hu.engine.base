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
    
    public func create(from scriptParameters: [String : String], strings: inout [String : String]) -> BaseScene {
        return BaseScene()
    }
    
    public func decode(from scriptParameters: [String : String], strings: inout [String : String]) throws {
    }
    
    public func decode(from decoder: Decoder, scene: BaseScene) throws {
    }
    
    open func encode(to encoder: Encoder, scene: BaseScene) throws {
    }
    
    open func getDescription(scene: BaseScene) -> String {
        return ""
    }
    
    open func toStringsHeader(scene: BaseScene, index: Int, strings: [String : String]) -> String {
        return ""
    }
    
    open func toScriptHeader(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        return ""
    }
    
    open func toStringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        return []
    }
    
    open func toScriptLines(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        return []
    }
}

open class GameSceneListSerialiser : BaseSceneSerialiser
{

}

public func RegisterGameSceneInitialisers(sceneListSerialiser: inout SceneListSerialiser) {
    sceneListSerialiser.serialisers.append(GameSceneListSerialiser())
}
