//
//  Session.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/3/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import UIKit

class Session: ObservableObject, Identifiable, Hashable {
    
    @Published var image: UIImage
    @Published var contents: Contents
    
    var devices: Set<Device> {
        set { contents.devices = newValue }
        get { return Set<Device>(contents.devices) }
    }
    
    var appIconSet: AppIconSet {
        set { contents.appIconSet = newValue }
        get { return contents.appIconSet }
    }
    
    let id: String
    let url: URL
    var iconSetUrl: URL { url(for: "AppIcon.appiconset") }
    var contentsUrl: URL { url(for: "Contents.plist") }
    
    private let fileManager = FileManager.default
    
    init(identifier: String = UUID().uuidString) throws {
        self.id = identifier
        self.image = UIImage()
        self.contents = Contents(id: identifier)
        
        // Get documents directory
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
            throw SessionError.notFound
        }

        // Get url of specific session
        self.url = documentDirectory.appendingPathComponent("Sessions/\(id)")

        // Existing session
        if fileManager.fileExists(atPath: contentsUrl.path) {
            // Load Info data
            guard let data = fileManager.contents(atPath: contentsUrl.path) else {
                throw SessionError.notFound
            }
            self.contents = try PropertyListDecoder().decode(Contents.self, from: data)
            
            self.image = image(for: IconAsset(assetType: .appStore, scale: 1)) ?? UIImage()
        }
    }
    
    private func url(for component: String) -> URL {
        return url.appendingPathComponent(component)
    }
    
    var thumbnail: UIImage? {
        return image(for: IconAsset(assetType: .iPhoneApp, scale: 2))
    }
    
    func image(for asset: IconAsset) -> UIImage? {
        let url = iconSetUrl.appendingPathComponent(asset.filename)
        guard let imageData = try? Data(contentsOf: url),
            let image = UIImage(data: imageData) else {
                return self.image.resize(to: asset.size)
        }
        return image
    }
    
    struct Contents: Codable {
        let id: String
        let dateCreated: Date
        var lastModified: Date
        var devices: Set<Device> {
            didSet {  appIconSet = AppIconSet(assets: devices.reduce([], { $0 + $1.assets })) }
        }
        var appIconSet: AppIconSet

        public init(id: String = "", dateCreated: Date = Date(), lastModified: Date = Date(), devices: Set<Device> = [], appIconSet: AppIconSet = AppIconSet(assets: [])) {
            self.id = id
            self.dateCreated = dateCreated
            self.lastModified = lastModified
            self.devices = devices
            self.appIconSet = appIconSet
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
     
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }
}

/*
 1. Determine what idioms are needed (ipad, iphone, etc)
 2. Every scale for each idiom must be listed in Contents.json
 3. Match resulution * scale to existing icon size, create new if none
 4. Write all icons to folder AppIcon.appiconset. Write Contents.json to folder.
 */
extension Session {
    
    typealias AssetGeneratorCompletion = ((URL?, Error?) -> ())
    
    func generateAssets(progress: ((Double) -> ())?, completion: @escaping AssetGeneratorCompletion) {
        
        let iconSet = contents.appIconSet
        let fileManager = self.fileManager
        let url = iconSetUrl
        
        // Get destination directory
        // Check if image is large enough
        guard image.size.width >= 1024.0, image.size.height >= 1024.0,
            let image = image.fill(size: CGSize(width: 1024, height: 1024)) else {
                
            completion(nil, SessionError.imageTooSmall)
            return
        }

        progress?(0.0)
        
        DispatchQueue.global(qos: .background).async {
            
            let itemCount: Double = Double(iconSet.images.count + 1)
            
            do {
                for file in (try? fileManager.contentsOfDirectory(atPath: url.path)) ?? [] {
                    do {
                        try fileManager.removeItem(atPath: url.appendingPathComponent(file).path)
                    } catch {
                        print(error)
                    }
                }
                
                // Create iconSet folder
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                
                // Save resized images to icon set folder
                for (index, asset) in iconSet.assets.enumerated() {
                    
                    // Scale image accounting for UIImage's scale
                    let scaledImage = image.resize(to: asset.size / image.scale)
                    
                    // Resize UIImage to asset size
                    guard let imageData = scaledImage?.pngData() else {
                        completion(nil, SessionError.imageResize)
                        return
                    }
                    
                    fileManager.createFile(
                        atPath: url.appendingPathComponent(asset.filename).path,
                        contents: imageData,
                        attributes: nil
                    )
                    
                    DispatchQueue.main.async {
                        progress?(Double(index) / itemCount)
                    }
                }
             
                // Save Contents.json
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted]
                
                let contentsData = try encoder.encode(iconSet.contents)
                
                fileManager.createFile(
                    atPath: url.appendingPathComponent("Contents.json").path,
                    contents: contentsData,
                    attributes: nil
                )
                
                DispatchQueue.main.async {
                    progress?(1.0)
                    completion(url, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
    }
}

extension Session {
    static var all: [Session] {
        guard var sessionsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return []
        }
        sessionsDirectory.appendPathComponent("Sessions")
        
        var identifiers: [String] = (try? FileManager.default.contentsOfDirectory(atPath: sessionsDirectory.path)) ?? []
        identifiers = identifiers.filter {
            $0.contains("-")
        }
        
        let sessions: [Session] = identifiers.compactMap { try? Session(identifier: $0) }
        
        return sessions
    }
    
    /// Searches through saved sessions and removes any with missing assets
    static func prune() {
        Session.all.filter {
            $0.appIconSet.assets.isEmpty
        }.forEach {
            $0.delete()
        }
    }
}

extension Session {
    func delete() {
        try? fileManager.removeItem(at: url)
    }
    
    func save() throws {
        contents.lastModified = Date()
        
        // Save contents to Contents.plist
        let plistData = try PropertyListEncoder().encode(contents)
        fileManager.createFile(atPath: contentsUrl.path, contents: plistData, attributes: nil)
    }
}

enum SessionError: Error {
    case imageTooSmall
    case imageResize
    case notFound
}
