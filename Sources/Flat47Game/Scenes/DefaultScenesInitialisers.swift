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
    
    open func create(from scriptParameters: [String : String], strings: inout [String : String]) -> BaseScene? {
        return nil
    }
    
    open func decode(from scriptParameters: [String : String], strings: inout [String : String]) throws {
    }
    
    open func decode(from decoder: Decoder, scene: BaseScene) throws {
    }
    
    open func encode(to encoder: Encoder, scene: BaseScene) throws {
    }
    
    open func update(scene: BaseScene) -> BaseScene? {
        return nil
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

    open override func create(from scriptParameters: [String : String], strings: inout [String : String]) -> BaseScene {
        return BaseScene()
    }

    open override func decode(from scriptParameters: [String : String], strings: inout [String : String]) throws {
    }

    open override func decode(from decoder: Decoder, scene: BaseScene) throws {
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

    open override func toStringsHeader(scene: BaseScene, index: Int, strings: [String : String]) -> String {
        return ""
    }

    open override func toScriptHeader(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        return ""
    }

    open override func toStringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        return []
    }

    open override func toScriptLines(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        return []
    }
    
    open override func appendText(scene: BaseScene, text: String, textBucket: String, chapterNumber: String, sceneNumber: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
    }
/*
}*/

/*        */
/*if (textBucket.isEmpty) {
    let lineString = "line_\(lineIndex)"
    let lineReference = chapter + "_" + scene + "_" + lineString
            switch data.Scene {
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
//} else if (textBucket == "Solved") {
//    let lineString = "solved_line_\(lineIndex)"
//    let lineReference = chapter + "_" + scene + "_" + lineString
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

    /*switch data.Scene {
    case "Choice":
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

public func RegisterGameSceneInitialisers(sceneListSerialiser: inout SceneListSerialiser) {
    sceneListSerialiser.serialisers.append(GameSceneListSerialiser())
}
