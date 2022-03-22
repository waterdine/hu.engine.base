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
public struct StringsDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.package] }
    public var strings: [String : String] = [:]
    
    public init() {
    }
    
    public init(file: FileWrapper) throws {
        // Todo what happens if multiple .strings files?
        
        strings = try PropertyListSerialization.propertyList(from: (file.fileWrappers?.first(where: { $0.key.contains(".strings")})?.value.regularFileContents!)!, format: nil) as! [String : String]
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
    }
    
    public func fileWrapper() throws -> FileWrapper {
        var lines = ""
        for stringPair in strings {
            lines.append("\"" + stringPair.key + "\" = \"" + stringPair.value + "\";")
        }
        return FileWrapper(regularFileWithContents: lines.data(using: .utf8)!)
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
            mouthOpenWrapper?.preferredFilename = "MouthOpen.png"
            topDirectory.addFileWrapper(mouthOpenWrapper!)
        }
        if (mouthClosedWrapper != nil) {
            mouthClosedWrapper?.preferredFilename = "MouthClosed.png"
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
        self.languagesWrapper = file.fileWrappers?["Languages"] ?? FileWrapper(directoryWithFileWrappers: [:])
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
    }
    
    public func fetchLanguage(name: String) -> StringsDocument {
        let wrapperForLanguage = languagesWrapper.fileWrappers!["\(name).lproj"]
        return wrapperForLanguage == nil ? StringsDocument() : try! StringsDocument(file: wrapperForLanguage!)
    }
    
    public func setLanguage(name: String, language: StringsDocument) {
        let wrapperForLanguage = languagesWrapper.fileWrappers!["\(name).lproj"]
        if (wrapperForLanguage != nil) {
            languagesWrapper.removeFileWrapper(wrapperForLanguage!)
        }
        try! languagesWrapper.addFileWrapper(language.fileWrapper())
    }
    
    public func fileWrapper() throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        scenesWrapper.preferredFilename = "Scenes.plist"
        topDirectory.addFileWrapper(scenesWrapper)
        languagesWrapper.preferredFilename = "Languages"
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
        self.scriptsWrapper = file.fileWrappers?["Scripts"] ?? FileWrapper(directoryWithFileWrappers: [:])
        self.languagesWrapper = file.fileWrappers?["Languages"] ?? FileWrapper(directoryWithFileWrappers: [:])
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
        scriptsWrapper.addFileWrapper(try! script.fileWrapper())
    }
    
    public func fetchLanguage(name: String) -> StringsDocument {
        let wrapperForLanguage = languagesWrapper.fileWrappers!["\(name).lproj"]
        return wrapperForLanguage == nil ? StringsDocument() : try! StringsDocument(file: wrapperForLanguage!)
    }
    
    public func setLanguage(name: String, language: StringsDocument) {
        let wrapperForLanguage = languagesWrapper.fileWrappers!["\(name).lproj"]
        if (wrapperForLanguage != nil) {
            languagesWrapper.removeFileWrapper(wrapperForLanguage!)
        }
        languagesWrapper.addFileWrapper(try! language.fileWrapper())
    }
    
    public func fileWrapper() throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        storyWrapper.preferredFilename = "Story.plist"
        topDirectory.addFileWrapper(storyWrapper)
        scriptsWrapper.preferredFilename = "Scripts"
        topDirectory.addFileWrapper(scriptsWrapper)
        languagesWrapper.preferredFilename = "Languages"
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
            self.characterModelsWrapper = file.fileWrappers?["Images"]?.fileWrappers?["Characters"] ?? FileWrapper(directoryWithFileWrappers: [:])
            self.interfaceWrapper = file.fileWrappers?["Images"]?.fileWrappers?["Interface"] ?? FileWrapper(directoryWithFileWrappers: [:])
            self.scenesWrapper = file.fileWrappers?["Scenes"] ?? FileWrapper(directoryWithFileWrappers: [:])
            self.soundsWrapper = file.fileWrappers?["Sound"] ?? FileWrapper(directoryWithFileWrappers: [:])
            self.musicsWrapper = file.fileWrappers?["Music"] ?? FileWrapper(directoryWithFileWrappers: [:])
        } else {
            self.storyWrapper = file.fileWrappers?["\(product.name).虎story"]
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
        characterModelsWrapper?.addFileWrapper(try! characterModel.fileWrapper())
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
                backgroundsWrapper?.preferredFilename = "Backgrounds"
                imagesDirectory.addFileWrapper(backgroundsWrapper!)
            }
            if (characterModelsWrapper != nil) {
                characterModelsWrapper?.preferredFilename = "Characters"
                imagesDirectory.addFileWrapper(characterModelsWrapper!)
            }
            if (interfaceWrapper != nil) {
                interfaceWrapper?.preferredFilename = "Interface"
                imagesDirectory.addFileWrapper(interfaceWrapper!)
            }
            
            topDirectory.addFileWrapper(imagesDirectory)
            if (soundsWrapper != nil) {
                soundsWrapper?.preferredFilename = "Sound"
                topDirectory.addFileWrapper(soundsWrapper!)
            }
            if (musicsWrapper != nil) {
                musicsWrapper?.preferredFilename = "Music"
                topDirectory.addFileWrapper(musicsWrapper!)
            }
            if (scenesWrapper != nil) {
                scenesWrapper?.preferredFilename = "Scenes"
                topDirectory.addFileWrapper(scenesWrapper!)
            }
        } else {
            storyWrapper!.preferredFilename = "\(product.name).虎story"
            topDirectory.addFileWrapper(storyWrapper!)
        }
        return topDirectory
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try fileWrapper()
    }
}
