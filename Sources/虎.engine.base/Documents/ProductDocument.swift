//
//  EngineDocument.swift
//  
//
//  Created by ito.antonia on 06/03/2022.
//

import SwiftUI
import UniformTypeIdentifiers

// Define this document's type.
@available(macCatalyst 14.0, *)
@available(macOS 11.0, *)
public extension UTType {
    static let waterdineScriptDocument = UTType(exportedAs: "studio.waterdine.script")
    static let waterdineCharacterModelDocument = UTType(exportedAs: "studio.waterdine.charactermodel")
    static let waterdineStoryDocument = UTType(exportedAs: "studio.waterdine.story")
    static let waterdineProductDocument = UTType(exportedAs: "studio.waterdine.product")
}

@available(macCatalyst 14.0, *)
@available(macOS 11.0, *)
public struct LanguageDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.package] }
    
    public var stringsDocumentWrappers: [String:FileWrapper]
    
    public init() {
        stringsDocumentWrappers = [:]
    }
    
    public init(file: FileWrapper) throws {
        stringsDocumentWrappers = file.fileWrappers ?? [:]
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
    }
    
    public func fetchStrings(key: String, name: String) -> [String : String] {
        let wrapperForStringsDocument = stringsDocumentWrappers["\(name).strings"]
        var strings: [String : String] = [:]
        if (wrapperForStringsDocument != nil) {
            strings = try! PropertyListSerialization.propertyList(from: wrapperForStringsDocument!.regularFileContents!, format: nil) as! [String : String]
        }
        return strings
    }
    
    public mutating func setStrings(key: String, name: String, strings: [String : String]) {
        var lines = ""
        for stringPair in strings {
            lines.append("\"" + stringPair.key + "\" = \"" + stringPair.value + "\";")
        }
        let wrapperForStringsDocument = stringsDocumentWrappers["\(name).strings"]
        if (wrapperForStringsDocument != nil) {
            stringsDocumentWrappers.removeValue(forKey: "\(name).strings")
        }
        let newWrapperForStringsDocument = FileWrapper(regularFileWithContents: lines.data(using: .utf8)!)
        newWrapperForStringsDocument.preferredFilename = "\(name).strings"
        stringsDocumentWrappers["\(name).strings"] = newWrapperForStringsDocument
    }
    
    public func fileWrapper() throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        for stringsDocumentWrapper in stringsDocumentWrappers {
            topDirectory.addFileWrapper(stringsDocumentWrapper.value)
        }
        return topDirectory
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try fileWrapper()
    }
}

@available(macCatalyst 14.0, *)
@available(macOS 11.0, *)
public struct CharacterModelDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.waterdineCharacterModelDocument] }
    public var name: String = ""
    public var mouthOpenWrapper: FileWrapper? = nil
    public var mouthClosedWrapper: FileWrapper? = nil
    
    public init() {
    }

    public init(file: FileWrapper) throws {
        name = file.filename ?? ""
        mouthOpenWrapper = file.fileWrappers?["MouthOpen.png"]
        mouthClosedWrapper = file.fileWrappers?["MouthClosed.png"]
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
    }
    
    public func fileWrapper() throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        if (mouthOpenWrapper != nil) {
            topDirectory.addFileWrapper(mouthOpenWrapper!)
        }
        if (mouthClosedWrapper != nil) {
            topDirectory.addFileWrapper(mouthClosedWrapper!)
        }
        return topDirectory
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try fileWrapper()
    }
}

@available(macCatalyst 14.0, *)
@available(macOS 11.0, *)
public struct ScriptDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.waterdineScriptDocument] }
    public var name: String = ""
    public var scenesWrapper: FileWrapper
    public var languagesWrapper: FileWrapper
    
    public init() {
        self.scenesWrapper = FileWrapper(regularFileWithContents: Data())
        self.scenesWrapper.preferredFilename = "Scenes.plist"
        self.languagesWrapper = FileWrapper(directoryWithFileWrappers: [:])
        self.languagesWrapper.preferredFilename = "Languages"
    }

    public init(file: FileWrapper) throws {
        name = file.filename ?? ""
        self.scenesWrapper = file.fileWrappers?["Scenes.plist"] ?? FileWrapper(regularFileWithContents: Data())
        if (self.scenesWrapper.filename == nil) {
            self.scenesWrapper.preferredFilename = "Scenes.plist"
        }
        self.languagesWrapper = file.fileWrappers?["Languages"] ?? FileWrapper(directoryWithFileWrappers: [:])
        if (self.languagesWrapper.filename == nil) {
            self.languagesWrapper.preferredFilename = "Languages"
        }
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
    }
    
    public func fetchScenes(key: String, sceneListSerialiser: SceneListSerialiser) -> Scenes {
        /*let scriptsPlistContents = try! Data(contentsOf: scriptsPlistURL)
        var story: Story? = nil
        let scriptsPlistString: String? = String(data: scriptsPlistContents, encoding: .utf8)
        if (scriptsPlistString != nil && scriptsPlistString!.starts(with: "<?xml")) {
            story = try! PropertyListDecoder().decode(Story.self, from: scriptsPlistString!.data(using: .utf8)!)
        } else {
            let sealedBox = try! AES.GCM.SealedBox.init(combined: scriptsPlistContents)
            let key = SymmetricKey.init(data: masterKey())
            let data = try! AES.GCM.open(sealedBox, using: key)
            story = try! PropertyListDecoder().decode(Story.self, from: data)
        }*/
        let decoder: PropertyListDecoder = PropertyListDecoder()
        decoder.userInfo[SceneListSerialiser().userInfoKey!] = sceneListSerialiser
        return try! decoder.decode(Scenes.self, from: (scenesWrapper.regularFileContents)!)
    }
    
    public mutating func setScenes(key: String, scenes: Scenes, sceneListSerialiser: SceneListSerialiser) {
        /*let scriptsPlistData = try! encoder.encode(story)
        let scriptsPlistURL = productURL!.appendingPathComponent("Story").appendingPathExtension("plist")
        if (encoder.outputFormat == .binary) {
            let key = SymmetricKey.init(data: masterKey())
            let sealedBox = try! AES.GCM.seal(scriptsPlistData, using: key)
            try! sealedBox.combined!.write(to: scriptsPlistURL)
        } else {
            try! String(data: scriptsPlistData, encoding: .utf8)!.write(to: scriptsPlistURL, atomically: false, encoding: .utf8)
        }*/
        let encoder = PropertyListEncoder()
        encoder.userInfo[sceneListSerialiser.userInfoKey!] = sceneListSerialiser
        encoder.outputFormat = .xml
        let scenesPlistData = try! encoder.encode(scenes)
        scenesWrapper = FileWrapper(regularFileWithContents: scenesPlistData)
        self.scenesWrapper.preferredFilename = "Scenes.plist"
    }
    
    public func fetchLanguage(name: String) -> LanguageDocument {
        let wrapperForLanguage = languagesWrapper.fileWrappers!["\(name).lproj"]
        return wrapperForLanguage == nil ? LanguageDocument() : try! LanguageDocument(file: wrapperForLanguage!)
    }
    
    public func setLanguage(name: String, language: LanguageDocument) {
        let wrapperForLanguage = languagesWrapper.fileWrappers!["\(name).lproj"]
        if (wrapperForLanguage != nil) {
            languagesWrapper.removeFileWrapper(wrapperForLanguage!)
        }
        let newWrapperForLanguage = try! language.fileWrapper()
        newWrapperForLanguage.preferredFilename = "\(name).lproj"
        languagesWrapper.addFileWrapper(newWrapperForLanguage)
    }
    
    public func fileWrapper() throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        topDirectory.addFileWrapper(scenesWrapper)
        topDirectory.addFileWrapper(languagesWrapper)
        return topDirectory
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try fileWrapper()
    }
}

@available(macCatalyst 14.0, *)
@available(macOS 11, *)
public struct StoryDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.waterdineStoryDocument] }
    
    public var storyWrapper: FileWrapper
    public var scriptsWrapper: FileWrapper
    public var languagesWrapper: FileWrapper
    
    public init() {
        self.storyWrapper = FileWrapper(regularFileWithContents: Data())
        self.storyWrapper.preferredFilename = "Story.plist"
        self.scriptsWrapper = FileWrapper(directoryWithFileWrappers: [:])
        self.scriptsWrapper.preferredFilename = "Scripts"
        self.languagesWrapper = FileWrapper(directoryWithFileWrappers: [:])
        self.languagesWrapper.preferredFilename = "Languages"
    }
    
    public init(file: FileWrapper) throws {
        self.storyWrapper = file.fileWrappers?["Story.plist"] ?? FileWrapper(regularFileWithContents: Data())
        if (self.storyWrapper.filename == nil) {
            self.storyWrapper.preferredFilename = "Story.plist"
        }
        self.scriptsWrapper = file.fileWrappers?["Scripts"] ?? FileWrapper(directoryWithFileWrappers: [:])
        if (self.scriptsWrapper.filename == nil) {
            self.scriptsWrapper.preferredFilename = "Scripts"
        }
        self.languagesWrapper = file.fileWrappers?["Languages"] ?? FileWrapper(directoryWithFileWrappers: [:])
        if (self.languagesWrapper.filename == nil) {
            self.languagesWrapper.preferredFilename = "Languages"
        }
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
    }
    
    public func fetchStory(key: String) -> Story {
        let decoder: PropertyListDecoder = PropertyListDecoder()
        return try! decoder.decode(Story.self, from: (storyWrapper.regularFileContents)!)
    }
    
    public mutating func setStory(story: Story, key: String) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let storyPlistData = try! encoder.encode(story)
        storyWrapper = FileWrapper(regularFileWithContents: storyPlistData)
        storyWrapper.preferredFilename = "Story.plist"
    }
    
    public func fetchScript(name: String) -> ScriptDocument {
        let wrapperForScript = scriptsWrapper.fileWrappers!["\(name).虎script"]
        return wrapperForScript == nil ? ScriptDocument() : try! ScriptDocument(file: wrapperForScript!)
    }
    
    public func setScript(name: String, script: ScriptDocument) {
        let wrapperForScript = scriptsWrapper.fileWrappers!["\(name).虎script"]
        if (wrapperForScript != nil) {
            scriptsWrapper.removeFileWrapper(wrapperForScript!)
        }
        let newWrapperForScript = try! script.fileWrapper()
        newWrapperForScript.preferredFilename = "\(name).虎script"
        scriptsWrapper.addFileWrapper(newWrapperForScript)
    }
    
    public func fetchLanguage(name: String) -> LanguageDocument {
        let wrapperForLanguage = languagesWrapper.fileWrappers!["\(name).lproj"]
        return wrapperForLanguage == nil ? LanguageDocument() : try! LanguageDocument(file: wrapperForLanguage!)
    }
    
    public func setLanguage(name: String, language: LanguageDocument) {
        let wrapperForLanguage = languagesWrapper.fileWrappers!["\(name).lproj"]
        if (wrapperForLanguage != nil) {
            languagesWrapper.removeFileWrapper(wrapperForLanguage!)
        }
        let newWrapperForLanguage = try! language.fileWrapper()
        newWrapperForLanguage.preferredFilename = "\(name).lproj"
        languagesWrapper.addFileWrapper(newWrapperForLanguage)
    }
    
    public func fileWrapper() throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        topDirectory.addFileWrapper(storyWrapper)
        topDirectory.addFileWrapper(scriptsWrapper)
        topDirectory.addFileWrapper(languagesWrapper)
        return topDirectory
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try fileWrapper()
    }
}

@available(macCatalyst 14.0, *)
@available(macOS 11.0, *)
public struct ProductDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.waterdineProductDocument] }

    public var product: Product = Product()
    public var storyWrapper: FileWrapper? = nil
    public var backgroundsWrapper: FileWrapper? = nil
    public var characterModelsWrapper: FileWrapper? = nil
    public var soundsWrapper: FileWrapper? = nil
    public var musicsWrapper: FileWrapper? = nil
    public var scenesWrapper: FileWrapper? = nil
    public var interfaceWrapper: FileWrapper? = nil
    
    public init() {
    }
    
    public init(file: FileWrapper) throws {
        self.product = try PropertyListDecoder().decode(Product.self, from: (file.fileWrappers?["Product.plist"]?.regularFileContents)!)
        if (product.library) {
            self.backgroundsWrapper = file.fileWrappers?["Images"]?.fileWrappers?["Backgrounds"] ?? FileWrapper(directoryWithFileWrappers: [:])
            if (self.backgroundsWrapper!.filename == nil) {
                self.backgroundsWrapper!.preferredFilename = "Backgrounds"
            }
            self.characterModelsWrapper = file.fileWrappers?["Images"]?.fileWrappers?["Characters"] ?? FileWrapper(directoryWithFileWrappers: [:])
            if (self.characterModelsWrapper!.filename == nil) {
                self.characterModelsWrapper!.preferredFilename = "Characters"
            }
            self.interfaceWrapper = file.fileWrappers?["Images"]?.fileWrappers?["Interface"] ?? FileWrapper(directoryWithFileWrappers: [:])
            if (self.interfaceWrapper!.filename == nil) {
                self.interfaceWrapper!.preferredFilename = "Interface"
            }
            self.scenesWrapper = file.fileWrappers?["Scenes"] ?? FileWrapper(directoryWithFileWrappers: [:])
            if (self.scenesWrapper!.filename == nil) {
                self.scenesWrapper!.preferredFilename = "Scenes"
            }
            self.soundsWrapper = file.fileWrappers?["Sound"] ?? FileWrapper(directoryWithFileWrappers: [:])
            if (self.soundsWrapper!.filename == nil) {
                self.soundsWrapper!.preferredFilename = "Sound"
            }
            self.musicsWrapper = file.fileWrappers?["Music"] ?? FileWrapper(directoryWithFileWrappers: [:])
            if (self.musicsWrapper!.filename == nil) {
                self.musicsWrapper!.preferredFilename = "Music"
            }
        } else {
            self.storyWrapper = file.fileWrappers?["\(product.name).虎story"]
            if (self.storyWrapper!.filename == nil) {
                self.storyWrapper!.preferredFilename = "\(product.name).虎story"
            }
        }
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
    }
    
    public func listCharacterModels() -> [String] {
        // put this in a manifest?
        return characterModelsWrapper?.fileWrappers?.keys.map({ $0.replacingOccurrences(of: ".虎model", with: "") }) ?? []
    }
    
    public func fetchCharacterModels(name: String) -> CharacterModelDocument {
        let wrapperForCharacterModel = characterModelsWrapper?.fileWrappers?["\(name).虎model"]
        return wrapperForCharacterModel == nil ? CharacterModelDocument() : try! CharacterModelDocument(file: wrapperForCharacterModel!)
    }
    
    public func setCharacterModels(name: String, characterModel: CharacterModelDocument) {
        let wrapperForCharacterModel = characterModelsWrapper?.fileWrappers?["\(name).虎model"]
        if (wrapperForCharacterModel != nil) {
            characterModelsWrapper?.removeFileWrapper(wrapperForCharacterModel!)
        }
        let newWrapperForCharacterModel = try! characterModel.fileWrapper()
        newWrapperForCharacterModel.preferredFilename = "\(name).虎model"
        characterModelsWrapper?.addFileWrapper(newWrapperForCharacterModel)
    }
    
    public func fetchStory() -> StoryDocument {
        return try! StoryDocument(file: storyWrapper!)
    }
    
    public mutating func setStory(story: StoryDocument) {
        storyWrapper = try! story.fileWrapper()
    }
            
    public func fileWrapper() throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let productData = try encoder.encode(product)
        let productWrapper = FileWrapper(regularFileWithContents: productData)
        productWrapper.preferredFilename = "Product.plist"
        topDirectory.addFileWrapper(productWrapper)
        if (product.library) {
            let imagesDirectory = FileWrapper(directoryWithFileWrappers: [:])
            imagesDirectory.preferredFilename = "Images"
            if (backgroundsWrapper != nil) {
                imagesDirectory.addFileWrapper(backgroundsWrapper!)
            }
            if (characterModelsWrapper != nil) {
                imagesDirectory.addFileWrapper(characterModelsWrapper!)
            }
            if (interfaceWrapper != nil) {
                imagesDirectory.addFileWrapper(interfaceWrapper!)
            }
            
            topDirectory.addFileWrapper(imagesDirectory)
            if (soundsWrapper != nil) {
                topDirectory.addFileWrapper(soundsWrapper!)
            }
            if (musicsWrapper != nil) {
                topDirectory.addFileWrapper(musicsWrapper!)
            }
            if (scenesWrapper != nil) {
                topDirectory.addFileWrapper(scenesWrapper!)
            }
        } else {
            topDirectory.addFileWrapper(storyWrapper!)
        }
        return topDirectory
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try fileWrapper()
    }
}
