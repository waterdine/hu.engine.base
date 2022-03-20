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
    static let waterdineActorDocument = UTType(exportedAs: "studio.waterdine.actor")
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
public struct ActorDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.waterdineActorDocument] }
    public var mouthOpenWrapper: FileWrapper? = nil
    public var mouthClosedWrapper: FileWrapper? = nil
    
    public init() {
    }

    public init(file: FileWrapper) throws {
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
@available(macOS 11, *)
public struct StoryDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.waterdineStoryDocument] }
    
    public var story: Story? = nil
    public var scriptsWrapper: FileWrapper
    public var languagesWrapper: FileWrapper
    
    public init() {
        self.scriptsWrapper = FileWrapper(directoryWithFileWrappers: [:])
        self.languagesWrapper = FileWrapper(directoryWithFileWrappers: [:])
        //
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
    public var backgroundsWrapper: FileWrapper? = nil
    public var actorsWrapper: FileWrapper? = nil
    public var soundsWrapper: FileWrapper? = nil
    public var musicsWrapper: FileWrapper? = nil
    
    public init() {
    }
    
    public init(file: FileWrapper) throws {
        self.product = try PropertyListDecoder().decode(Product.self, from: (file.fileWrappers?["Product.plist"]?.regularFileContents)!)
        if (product.library) {
            self.backgroundsWrapper = file.fileWrappers?["Images"]?.fileWrappers?["Backgrounds"] ?? FileWrapper(directoryWithFileWrappers: [:])
            self.actorsWrapper = file.fileWrappers?["Images"]?.fileWrappers?["Actors"] ?? FileWrapper(directoryWithFileWrappers: [:])
            self.soundsWrapper = file.fileWrappers?["Sound"] ?? FileWrapper(directoryWithFileWrappers: [:])
            self.musicsWrapper = file.fileWrappers?["Music"] ?? FileWrapper(directoryWithFileWrappers: [:])
        } else {
            self.storyWrapper = file.fileWrappers?["\(product.name).虎story"]
        }
    }
    
    public init(configuration: ReadConfiguration) throws {
        try self.init(file: configuration.file)
    }
    
    public func listActors() -> [String] {
        // put this in a manifest?
        return actorsWrapper?.fileWrappers?.keys.map({ $0.replacingOccurrences(of: ".虎actor", with: "") }) ?? []
    }
    
    public func fetchActor(name: String) -> ActorDocument {
        let wrapperForActor = actorsWrapper?.fileWrappers?["\(name).虎actor"]
        return wrapperForActor == nil ? ActorDocument() : try! ActorDocument(file: wrapperForActor!)
    }
    
    public func setActor(name: String, script: ActorDocument) {
        let wrapperForActor = actorsWrapper?.fileWrappers?["\(name).虎actor"]
        if (wrapperForActor != nil) {
            actorsWrapper?.removeFileWrapper(wrapperForActor!)
        }
        actorsWrapper?.addFileWrapper(try! script.fileWrapper())
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
            if (backgroundsWrapper != nil) {
                backgroundsWrapper?.preferredFilename = "Backgrounds"
                imagesDirectory.addFileWrapper(backgroundsWrapper!)
            }
            if (actorsWrapper != nil) {
                actorsWrapper?.preferredFilename = "Actors"
                imagesDirectory.addFileWrapper(actorsWrapper!)
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
        } else {
            storyWrapper!.preferredFilename = "\(product.name).虎story"
            topDirectory.addFileWrapper(storyWrapper!)
        }
        return topDirectory
    }
}
