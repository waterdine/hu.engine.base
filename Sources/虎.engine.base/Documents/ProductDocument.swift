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
        //strings = NSDictionary.init(data: file.fileWrappers?["Product.plist"]?.regularFileContents) as! [String : String]
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
public struct ScriptDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.waterdineScriptDocument] }
    public var scenesWrapper: FileWrapper? = nil
    public var languagesWrapper: FileWrapper
    
    public init() {
        self.languagesWrapper = FileWrapper(directoryWithFileWrappers: [:])
    }

    public init(file: FileWrapper) throws {
        self.scenesWrapper = file.fileWrappers?["Scenes.plist"]
        self.languagesWrapper = file.fileWrappers?["Languages"] ?? FileWrapper(directoryWithFileWrappers: [:])
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
    }
    
    public func fetchScenes(sceneListSerialiser: SceneListSerialiser) -> Scenes {
        let decoder: PropertyListDecoder = PropertyListDecoder()
        decoder.userInfo[SceneListSerialiser().userInfoKey!] = sceneListSerialiser
        return try! decoder.decode(Scenes.self, from: (scenesWrapper?.regularFileContents)!)
    }
    
    public mutating func setScenes(scenes: Scenes, sceneListSerialiser: SceneListSerialiser) {
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
        scenesWrapper?.preferredFilename = "Scenes.plist"
        topDirectory.addFileWrapper(scenesWrapper!)
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
public struct StoryDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.waterdineStoryDocument] }
    
    public var story: Story? = nil
    public var scriptsWrapper: FileWrapper
    public var languagesWrapper: FileWrapper
    
    public init() {
        self.scriptsWrapper = FileWrapper(directoryWithFileWrappers: [:])
        self.languagesWrapper = FileWrapper(directoryWithFileWrappers: [:])
    }
    
    public init(file: FileWrapper) throws {
        self.story = try PropertyListDecoder().decode(Story.self, from: (file.fileWrappers?["Story.plist"]?.regularFileContents)!)
        self.scriptsWrapper = file.fileWrappers?["Scripts"] ?? FileWrapper(directoryWithFileWrappers: [:])
        self.languagesWrapper = file.fileWrappers?["Languages"] ?? FileWrapper(directoryWithFileWrappers: [:])
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
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
        let storyData = try PropertyListEncoder().encode(story)
        let storyWrapper = FileWrapper(regularFileWithContents: storyData)
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
    public var backgrounds: FileWrapper? = nil
    public var actors: FileWrapper? = nil
    public var sounds: FileWrapper? = nil
    public var musics: FileWrapper? = nil
    
    public init() {
    }
    
    public init(configuration: ReadConfiguration) throws {
        self.product = try PropertyListDecoder().decode(Product.self, from: (configuration.file.fileWrappers?["Product.plist"]?.regularFileContents)!)
        if (product.library) {
            self.backgrounds = configuration.file.fileWrappers?["Images"]?.fileWrappers?["Backgrounds"]
            self.actors = configuration.file.fileWrappers?["Images"]?.fileWrappers?["Characters"]
            self.sounds = configuration.file.fileWrappers?["Sound"]
            self.musics = configuration.file.fileWrappers?["Music"]
        } else {
            self.storyWrapper = configuration.file.fileWrappers?["\(product.name).虎story"]
        }
    }
    
    public func fetchStory() -> StoryDocument {
        return try! StoryDocument(file: storyWrapper!)
    }
    
    public mutating func setStory(story: StoryDocument) {
        storyWrapper = try! story.fileWrapper()
    }
            
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        let productData = try PropertyListEncoder().encode(product)
        let productWrapper = FileWrapper(regularFileWithContents: productData)
        productWrapper.preferredFilename = "Product.plist"
        topDirectory.addFileWrapper(productWrapper)
        if (product.library) {
            let imagesDirectory = FileWrapper(directoryWithFileWrappers: [:])
            imagesDirectory.preferredFilename = "Images"
            if (backgrounds != nil) {
                backgrounds?.preferredFilename = "Backgrounds"
                imagesDirectory.addFileWrapper(backgrounds!)
            }
            if (actors != nil) {
                actors?.preferredFilename = "Characters"
                imagesDirectory.addFileWrapper(actors!)
            }
            
            topDirectory.addFileWrapper(imagesDirectory)
            if (sounds != nil) {
                sounds?.preferredFilename = "Sound"
                topDirectory.addFileWrapper(sounds!)
            }
            if (musics != nil) {
                musics?.preferredFilename = "Music"
                topDirectory.addFileWrapper(musics!)
            }
        } else {
            storyWrapper!.preferredFilename = "\(product.name).虎story"
            topDirectory.addFileWrapper(storyWrapper!)
        }
        return topDirectory
    }
}
