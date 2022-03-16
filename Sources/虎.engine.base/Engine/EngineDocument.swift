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
    
    public var product: Product = Product()
    public var story: Story? = nil
    public var storyStrings: [String : FileWrapper] = [:] // Convert to subdocument .lprod
    public var scripts: [String : Scenes] = [:] // Convert to subdocument .lprod
    public var scriptStrings: FileWrapper? = nil // Convert to subdocument .lprod
    public var backgrounds: FileWrapper? = nil
    public var actors: FileWrapper? = nil
    public var sounds: FileWrapper? = nil
    public var musics: FileWrapper? = nil
    
    public init() {
    }

    public init(configuration: ReadConfiguration) throws {
        self.product = try PropertyListDecoder().decode(Product.self, from: (configuration.file.fileWrappers?["Property.plist"]?.regularFileContents)!)
        if (product.library) {
            self.backgrounds = configuration.file.fileWrappers?["Images"]?.fileWrappers?["Backgrounds"]
            self.actors = configuration.file.fileWrappers?["Images"]?.fileWrappers?["Characters"]
            self.sounds = configuration.file.fileWrappers?["Sound"]
            self.musics = configuration.file.fileWrappers?["Music"]
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
            let storyData = try PropertyListEncoder().encode(story)
            let storyWrapper = FileWrapper(regularFileWithContents: storyData)
            storyWrapper.preferredFilename = "Story.plist"
            topDirectory.addFileWrapper(storyWrapper)
        }
        return topDirectory
    }
}
