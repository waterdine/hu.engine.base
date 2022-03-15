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
    static let engineDocument = UTType(exportedAs: "engine.xn--y71a.product")
}

@available(macCatalyst 14.0, *)
@available(macOS 11.0, *)
public struct EngineDocument: FileDocument {
    
    public static var readableContentTypes: [UTType] { [.engineDocument] }
    
    var product: Product = Product()
    var story: Story? = nil
    var storyStrings: [String : FileWrapper] = [:] // Convert to subdocument .lprod
    var scripts: [String : Scenes] = [:] // Convert to subdocument .lprod
    var scriptStrings: [String : FileWrapper] = [:] // Convert to subdocument .lprod
    var backgrounds: [String : FileWrapper] = [:]
    var actors: [String : FileWrapper] = [:]
    var sounds: [String : FileWrapper] = [:]
    var musics: [String : FileWrapper] = [:]
    
    public init() {
    }

    public init(configuration: ReadConfiguration) throws {
        self.product = try PropertyListDecoder().decode(Product.self, from: (configuration.file.fileWrappers?["Property.plist"]?.regularFileContents)!)
        if (product.library) {
            self.backgrounds = configuration.file.fileWrappers?["Images"]?.fileWrappers?["Backgrounds"]?.fileWrappers ?? [:]
            self.actors = configuration.file.fileWrappers?["Images"]?.fileWrappers?["Characters"]?.fileWrappers ?? [:]
            self.sounds = configuration.file.fileWrappers?["Sounds"]?.fileWrappers ?? [:]
            self.musics = configuration.file.fileWrappers?["Music"]?.fileWrappers ?? [:]
        } else {
            self.story = try PropertyListDecoder().decode(Story.self, from: (configuration.file.fileWrappers?["Story.plist"]?.regularFileContents)!)
        }
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let topDirectory = FileWrapper(directoryWithFileWrappers: [:])
        let productData = try PropertyListEncoder().encode(product)
        let productWrapper = FileWrapper(regularFileWithContents: productData)
        productWrapper.preferredFilename = "Property.plist"
        topDirectory.addFileWrapper(productWrapper)
        if (product.library) {
            let imagesDirectory = FileWrapper(directoryWithFileWrappers: [:])
            imagesDirectory.preferredFilename = "Images"
            let backgroundsDirectory = FileWrapper(directoryWithFileWrappers: [:])
            backgroundsDirectory.preferredFilename = "Backgrounds"
            let charactersDirectory = FileWrapper(directoryWithFileWrappers: [:])
            charactersDirectory.preferredFilename = "Characters"
            imagesDirectory.addFileWrapper(backgroundsDirectory)
            imagesDirectory.addFileWrapper(charactersDirectory)
            
            let soundDirectory = FileWrapper(directoryWithFileWrappers: [:])
            soundDirectory.preferredFilename = "Sound"
            for sound in sounds {
                soundDirectory.addFileWrapper(sound.value)
            }
            let musicDirectory = FileWrapper(directoryWithFileWrappers: [:])
            for music in musics {
                musicDirectory.addFileWrapper(music.value)
            }
            musicDirectory.preferredFilename = "Music"
            
            topDirectory.addFileWrapper(imagesDirectory)
            topDirectory.addFileWrapper(soundDirectory)
            topDirectory.addFileWrapper(musicDirectory)
        } else {
            let storyData = try PropertyListEncoder().encode(story)
            let storyWrapper = FileWrapper(regularFileWithContents: storyData)
            storyWrapper.preferredFilename = "Story.plist"
            topDirectory.addFileWrapper(storyWrapper)
        }
        return topDirectory
    }
}
