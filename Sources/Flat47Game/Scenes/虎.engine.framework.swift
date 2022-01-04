//
//  虎.engine.framework.swift
//  Shared
//
//  Created by A. A. Bills on 28/07/2021.
//

import SwiftUI
import Combine
import SpriteKit

let FRAMEWORK_VERSION = 0

class FrameworkParser
{
    
}

class SceneWrapper: Identifiable, Codable {
    var id: UUID = UUID()
    var data: BaseScene = BaseScene()
    
    enum SceneKeys: String, CodingKey {
        case Scene
    }
    
    init() {
        
    }
    
    init(frameworkParser: FrameworkParser, scriptLine: String, label: String, strings: inout [String : String], chapterString: String, sceneString: inout String, sceneLabelMap: inout [String : Int]) {
        let scriptLineSplit = scriptLine.split(separator: ",")
        let sceneTypeSplit = scriptLineSplit[0].split(separator: "-")
        let sceneType: String = String(sceneTypeSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":"])
        var parameters: [String : String] = ["Scene" : sceneType]
        for parameterCombined in scriptLineSplit {
            if (!parameterCombined.starts(with: "// Scene")) {
                let parameterSplit = parameterCombined.split(separator: ":")
                let parameter = String(parameterSplit[0]).trimmingCharacters(in: [" ", "-", ",", ":"])
                let value = String(parameterSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":"])
                parameters[parameter] = value
            }
        }
        
        parameters["Chapter"] = chapterString
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

        /*switch sceneType {
        case "Intro":
            data = IntroScene.init(from: parameters, strings: &strings)
            break
        case "Story":
            data = StoryScene.init(from: parameters, strings: &strings)
            break
        case "CutScene":
            data = CutSceneScene.init(from: parameters, strings: &strings)
            break
        case "SkipTo":
            data = SkipToScene.init(from: parameters, strings: &strings)
            break
        case "Choice":
            data = ChoiceScene.init(from: parameters, strings: &strings)
            break
        case "ChapterTransition":
            data = ChapterTransitionScene.init(from: parameters, strings: &strings)
            break
        case "DatePuzzle":
            data = DatePuzzleScene.init(from: parameters, strings: &strings)
            break
        case "ZenPuzzle":
            data = ZenPuzzleScene.init(from: parameters, strings: &strings)
            break
        default:
            data = BaseScene.init(from: parameters, strings: &strings)
            break
        }*/
        //data = frameworkParser.
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SceneKeys.self)
        let Scene = try container.decode(String.self, forKey: SceneKeys.Scene)
/*        switch Scene {
        case "Intro":
            data = try IntroScene.init(from: decoder)
            break
        case "Story":
            data = try StoryScene.init(from: decoder)
            break
        case "CutScene":
            data = try CutSceneScene.init(from: decoder)
            break
        case "SkipTo":
            data = try SkipToScene.init(from: decoder)
            break
        case "Choice":
            data = try ChoiceScene.init(from: decoder)
            break
        case "ChapterTransition":
            data = try ChapterTransitionScene.init(from: decoder)
            break
        case "DatePuzzle":
            data = try DatePuzzleScene.init(from: decoder)
            break
        case "ZenPuzzle":
            data = try ZenPuzzleScene.init(from: decoder)
            break
        default:
            data = try BaseScene.init(from: decoder)
            break
        }*/
    }
    
    func encode(to encoder: Encoder) throws {
/*        switch data.Scene {
        case "Intro":
            try (data as! IntroScene).encode(to: encoder)
            break
        case "Story":
            try (data as! StoryScene).encode(to: encoder)
            break
        case "CutScene":
            try (data as! CutSceneScene).encode(to: encoder)
            break
        case "SkipTo":
            try (data as! SkipToScene).encode(to: encoder)
            break
        case "Choice":
            try (data as! ChoiceScene).encode(to: encoder)
            break
        case "ChapterTransition":
            try (data as! ChapterTransitionScene).encode(to: encoder)
            break
        case "DatePuzzle":
            try (data as! DatePuzzleScene).encode(to: encoder)
            break
        case "ZenPuzzle":
            try (data as! ZenPuzzleScene).encode(to: encoder)
            break
        default:
            try data.encode(to: encoder)
            break
        }*/
    }
    
    func update()
    {
        var newData: BaseScene = data
/*        switch data.Scene {
        case "Intro":
            if (!(data is IntroScene)) {
                newData = IntroScene()
            }
            break
        case "Story":
            if (!(data is StoryScene)) {
                newData = StoryScene()
            }
            break
        case "CutScene":
            if (!(data is CutSceneScene)) {
                newData = CutSceneScene()
            }
            break
        case "SkipTo":
            if (!(data is SkipToScene)) {
                newData = SkipToScene()
            }
            break
        case "Choice":
            if (!(data is ChoiceScene)) {
                newData = ChoiceScene()
            }
            break
        case "ChapterTransition":
            if (!(data is ChapterTransitionScene)) {
                newData = ChapterTransitionScene()
            }
            break
        case "DatePuzzle":
            if (!(data is DatePuzzleScene)) {
                newData = DatePuzzleScene()
            }
            break
        case "ZenPuzzle":
            if (!(data is ZenPuzzleScene)) {
                newData = ZenPuzzleScene()
            }
            break
        default:
            newData = BaseScene()
            break
        }*/
        newData.Scene = data.Scene
        newData.Label = data.Label
        data = newData
    }
    
    func getDescription() -> String {
/*        switch data.Scene {
        case "Intro":
            return (data as! IntroScene).getDescription()
        case "Story":
            return (data as! StoryScene).getDescription()
        case "CutScene":
            return (data as! CutSceneScene).getDescription()
        case "SkipTo":
            return (data as! SkipToScene).getDescription()
        case "Choice":
            return (data as! ChoiceScene).getDescription()
        case "ChapterTransition":
            return (data as! ChapterTransitionScene).getDescription()
        case "DatePuzzle":
            return (data as! DatePuzzleScene).getDescription()
        case "ZenPuzzle":
            return (data as! ZenPuzzleScene).getDescription()
        default:
            return ""
        }*/
        return ""
    }
    
    func appendText(text: String, textBucket: String, chapter: String, scene: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
        let line: TextLine = TextLine()
        line.textString = text
        if (textBucket.isEmpty) {
            let lineString = "line_\(lineIndex)"
            let lineReference = chapter + "_" + scene + "_" + lineString
/*            switch data.Scene {
            case "Story":
                if (!command) {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                }
                (data as! StoryScene).Text.append(line)
                break
            case "CutScene":
                if (!command) {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                }
                (data as! CutSceneScene).Text.append(line)
                break
            case "ZenPuzzle":
                if (text.starts(with: "Question")) {
                    (data as! ZenPuzzleScene).Question = chapter + "_" + scene + "_question"
                    strings[(data as! ZenPuzzleScene).Question!] = text.replacingOccurrences(of: "Question: ", with: "")
                } else {
                    if (!command) {
                        strings[lineReference] = String(text)
                        line.textString = lineReference
                    }
                    if ((data as! ZenPuzzleScene).Text == nil) {
                        (data as! ZenPuzzleScene).Text = []
                    }
                    (data as! ZenPuzzleScene).Text!.append(line)
                }
                break
            case "DatePuzzle":
                if (text.starts(with: "Question")) {
                    (data as! DatePuzzleScene).Question = chapter + "_" + scene + "_question"
                    strings[(data as! DatePuzzleScene).Question] = text.replacingOccurrences(of: "Question: ", with: "")
                } else if (text.starts(with: "Answer")) {
                    (data as! DatePuzzleScene).Answer = chapter + "_" + scene + "_answer"
                    strings[(data as! DatePuzzleScene).Answer] = text.replacingOccurrences(of: "Answer: ", with: "")
                } else {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                    (data as! DatePuzzleScene).Text.append(line)
                }
                break
            case "Choice":
                if (text.starts(with: "DirectingText")) {
                    (data as! ChoiceScene).DirectingText = chapter + "_" + scene + "_direction"
                    strings[(data as! ChoiceScene).DirectingText] = text.replacingOccurrences(of: "DirectingText: ", with: "")
                } else if (text.starts(with: "Choice")) {
                    let choiceSplit = text.replacingOccurrences(of: "//", with: "±").split(separator: "±")
                    let choiceTextSplit = choiceSplit[0].split(separator: ":")
                    let choiceNumber: String = String(choiceTextSplit[0]).replacingOccurrences(of: "Text", with: "").replacingOccurrences(of: "Choice", with: "").trimmingCharacters(in: [" ", "-", ",", ":", "/"])
                    let choiceText: String = String(choiceTextSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":", "/"])
                    var choiceParameters: [String : String] = ["Text" : choiceText]
                    choiceParameters["Choice"] = choiceNumber
                    if (choiceSplit.count > 1) {
                        let choiceParameterSplit = choiceSplit[1].split(separator: ",")
                        for parameterCombined in choiceParameterSplit {
                            if (!parameterCombined.starts(with: "Choice")) {
                                let parameterSplit = parameterCombined.split(separator: ":")
                                let parameter = String(parameterSplit[0]).trimmingCharacters(in: [" ", "-", ",", ":"])
                                let value = String(parameterSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":"])
                                choiceParameters[parameter] = value
                            }
                        }
                    }
                    
                    // Map the SkipTos to SceneLabels
                    if (choiceParameters["SkipTo"] != nil) {
                        var newSkipTo = ""
                        for skipToUntrimmed in choiceParameters["SkipTo"]!.split(separator: ";") {
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
                        choiceParameters["SkipTo"] = newSkipTo
                    }
                    
                    choiceParameters["Chapter"] = chapter
                    choiceParameters["SceneNumber"] = scene
                    let choice = Choice.init(from: choiceParameters, strings: &strings)
                    let choiceIndex = Int(choiceNumber)!
                    // atode: Check choiceIndex > 0 and handle it otherwise
                    if ((data as! ChoiceScene).Choices == nil) {
                        (data as! ChoiceScene).Choices = []
                    }
                    
                    for _ in (data as! ChoiceScene).Choices!.count..<choiceIndex {
                        (data as! ChoiceScene).Choices!.append(Choice())
                    }
                    (data as! ChoiceScene).Choices?[choiceIndex - 1] = choice
                }
            case "ChapterTransition":
                if (text.starts(with: "HorizontalNumber")) {
                    (data as! ChapterTransitionScene).HorizontalNumber = chapter + "_horizontal_number"
                    strings[(data as! ChapterTransitionScene).HorizontalNumber] = text.replacingOccurrences(of: "HorizontalNumber: ", with: "")
                } else if (text.starts(with: "HorizontalTitle")) {
                    (data as! ChapterTransitionScene).HorizontalTitle = chapter + "_horizontal_title"
                    strings[(data as! ChapterTransitionScene).HorizontalTitle] = text.replacingOccurrences(of: "HorizontalTitle: ", with: "")
                } else if (text.starts(with: "VerticalNumber")) {
                    (data as! ChapterTransitionScene).VerticalNumber = chapter + "_vertical_number"
                    strings[(data as! ChapterTransitionScene).VerticalNumber] = text.replacingOccurrences(of: "VerticalNumber: ", with: "")
                } else if (text.starts(with: "VerticalTitle")) {
                    (data as! ChapterTransitionScene).VerticalTitle = chapter + "_vertical_title"
                    strings[(data as! ChapterTransitionScene).VerticalTitle] = text.replacingOccurrences(of: "VerticalTitle: ", with: "")
                }
            default: break
            }*/
        } else if (textBucket == "Solved") {
            let lineString = "solved_line_\(lineIndex)"
            let lineReference = chapter + "_" + scene + "_" + lineString
            /*switch data.Scene {
            case "ZenPuzzle":
                if (!command) {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                }
                if ((data as! ZenPuzzleScene).SolvedText == nil) {
                    (data as! ZenPuzzleScene).SolvedText = []
                }
                (data as! ZenPuzzleScene).SolvedText!.append(line)
                break
            default: break
            }*/
        }
    }
    
    func stringsLines(index: Int, strings: [String : String]) -> [String] {
        var stringsLines: [String] = []
    /*    switch data.Scene {
        case "Intro":
            stringsLines.append(contentsOf: (data as! IntroScene).toStringsLines(index: index, strings: strings))
            break
        case "Story":
            stringsLines.append(contentsOf: (data as! StoryScene).toStringsLines(index: index, strings: strings))
            for textLine in (data as! StoryScene).Text {
                if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                    stringsLines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                }
            }
            break
        case "CutScene":
            stringsLines.append(contentsOf: (data as! CutSceneScene).toStringsLines(index: index, strings: strings))
            for textLine in (data as! CutSceneScene).Text {
                if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                    stringsLines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                }
            }
            break
        case "SkipTo":
            stringsLines.append(contentsOf: (data as! SkipToScene).toStringsLines(index: index, strings: strings))
            break
        case "Choice":
            stringsLines.append(contentsOf: (data as! ChoiceScene).toStringsLines(index: index, strings: strings))
            stringsLines.append("\"" + (data as! ChoiceScene).DirectingText + "\" = \"" + strings[(data as! ChoiceScene).DirectingText]! + "\";")
            for choice in (data as! ChoiceScene).Choices! {
                stringsLines.append("\"" + choice.Text + "\" = \"" + strings[choice.Text]! + "\";")
            }
            break
        case "ChapterTransition":
            stringsLines.append("/* " + strings[(data as! ChapterTransitionScene).HorizontalNumber]! + " */\n")
            stringsLines.append(contentsOf: (data as! ChapterTransitionScene).toStringsLines(index: index, strings: strings))
            stringsLines.append("\"" + (data as! ChapterTransitionScene).HorizontalNumber + "\" = \"" + strings[(data as! ChapterTransitionScene).HorizontalNumber]! + "\";")
            stringsLines.append("\"" + (data as! ChapterTransitionScene).HorizontalTitle + "\" = \"" + strings[(data as! ChapterTransitionScene).HorizontalTitle]! + "\";")
            stringsLines.append("\"" + (data as! ChapterTransitionScene).VerticalNumber + "\" = \"" + strings[(data as! ChapterTransitionScene).VerticalNumber]! + "\";")
            stringsLines.append("\"" + (data as! ChapterTransitionScene).VerticalTitle + "\" = \"" + strings[(data as! ChapterTransitionScene).VerticalTitle]! + "\";")
            break
        case "DatePuzzle":
            stringsLines.append(contentsOf: (data as! DatePuzzleScene).toStringsLines(index: index, strings: strings))
            for textLine in (data as! DatePuzzleScene).Text {
                if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                    stringsLines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                }
            }
            stringsLines.append("\"" + (data as! DatePuzzleScene).Question + "\" = \"" + strings[(data as! DatePuzzleScene).Question]! + "\";")
            stringsLines.append("\"" + (data as! DatePuzzleScene).Answer + "\" = \"" + strings[(data as! DatePuzzleScene).Answer]! + "\";")
            break
        case "ZenPuzzle":
            stringsLines.append(contentsOf: (data as! ZenPuzzleScene).toStringsLines(index: index, strings: strings))
            if ((data as! ZenPuzzleScene).Text != nil) {
                for textLine in (data as! ZenPuzzleScene).Text! {
                    if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                        stringsLines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                    }
                }
            }
            if ((data as! ZenPuzzleScene).SolvedText != nil) {
                stringsLines.append("// Solved Text")
                for textLine in (data as! ZenPuzzleScene).SolvedText! {
                    if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                        stringsLines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                    }
                }
            }
            break
        default:
            break
        }*/
        
        return stringsLines
    }

    func resolveSkipToIndexes(indexMap: [Int : Int]) {
        /*switch data.Scene {
        case "Choice":
            // Lucia's Boop!
            for (index, item) in (data as! ChoiceScene).Choices!.enumerated() {
                if (item.SkipTo != nil && indexMap[item.SkipTo!] != nil) {
                    (data as! ChoiceScene).Choices![index].SkipTo = indexMap[item.SkipTo!]!
                }
            }
            break
        case "SkipTo":
            if (indexMap[(data as! SkipToScene).SkipTo] != nil) {
                (data as! SkipToScene).SkipTo = indexMap[(data as! SkipToScene).SkipTo]!
            }
            break
        case "DatePuzzle":
            if (indexMap[(data as! DatePuzzleScene).SkipTo] != nil) {
                (data as! DatePuzzleScene).SkipTo = indexMap[(data as! DatePuzzleScene).SkipTo]!
            }
            break
        default: break
        }*/
    }
}

struct Scenes: Codable {
    var Scenes: [SceneWrapper] = []
}
