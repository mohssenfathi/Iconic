//
//  SessionProtocol.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/18/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import UIKit

protocol SessionProtocol {
    typealias AssetGeneratorCompletion = ((URL?, Error?) -> ())
    
    var id: String { get }
    var title: String { get }
    var url: URL { get }
    var iconSetUrl: URL  { get }
    var contentsUrl: URL  { get }
    var devices: Set<Device> { get set }
    var appIconSet: AppIconSet { get set }
    var fileManager: FileManager { get }
    var image: UIImage { get set }
    var contents: SessionContents { get set }
    
    static var all: [Session] { get }
    
    func generateAssets(progress: ((Double) -> ())?, completion: @escaping AssetGeneratorCompletion)
    func delete()
    func save() throws
}

// MARK: - Default Implementation
extension SessionProtocol {
    
    var iconSetUrl: URL { url(for: "AppIcon.appiconset") }
    var contentsUrl: URL { url(for: "Contents.plist") }
    
    var appIconSet: AppIconSet {
        set { contents.appIconSet = newValue }
        get { return contents.appIconSet }
    }
    
    func url(for component: String) -> URL {
        return url.appendingPathComponent(component)
    }
    
    func imageUrl(imageName: String) -> URL {
        return iconSetUrl.appendingPathComponent(imageName)
    }
    
    var thumbnail: UIImage? {
        return getImage(for: IconAsset(assetType: .iPhoneApp, scale: 2))
    }
    
    func getImage(for asset: IconAsset) -> UIImage? {
        let url = iconSetUrl.appendingPathComponent(asset.filename)
        guard let imageData = try? Data(contentsOf: url),
            let image = UIImage(data: imageData) else {
                return self.image.resize(to: asset.size)
        }
        return image
    }
    
    func validate(image: UIImage?) -> Error? {
       guard let image = image else {
           return SessionError.notFound
       }
       
       guard image.size.width >= 1024.0,
           image.size.height >= 1024.0 else {
               return SessionError.imageTooSmall
       }
       return nil
   }
    
    var assets: [IconAsset] {
        return contents.appIconSet.assets
    }
    
    var contentImages: [AppIconSet.Contents.Image] {
        return contents.appIconSet.images
    }
}


// MARK: - Asset Generation
/*
 1. Determine what idioms are needed (ipad, iphone, etc)
 2. Every scale for each idiom must be listed in Contents.json
 3. Match resulution * scale to existing icon size, create new if none
 4. Write all icons to folder AppIcon.appiconset. Write Contents.json to folder.
 */
extension SessionProtocol {
    
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
