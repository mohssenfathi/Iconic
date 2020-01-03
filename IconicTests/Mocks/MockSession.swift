//
//  MockSession.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/13/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import UIKit
@testable import Iconic

class MockSession: SessionProtocol {
    
    var id: String
    var title: String
    var url: URL
    var image: UIImage
    var devices: Set<Device>
    var fileManager: FileManager = FileManager.default
    var contents: SessionContents
    
    init(identifier: String = UUID().uuidString,
         image: UIImage = UIImage(color: .clear, size: CGSize(width: 1024, height: 1024)) ?? UIImage(),
         devices: Set<Device> = []) throws {
        
        self.id = identifier
        self.title = "Mock Session"
        self.image = image
        self.devices = devices
        self.contents = SessionContents(
            id: identifier,
            devices: devices,
            appIconSet: AppIconSet(assets: devices.reduce([], { $0 + $1.assets }))
        )
        
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
            self.contents = try PropertyListDecoder().decode(SessionContents.self, from: data)
            
            self.image = getImage(for: IconAsset(assetType: .appStore, scale: 1)) ?? UIImage()
        }
    }

//    init(id: String = UUID().uuidString, image: UIImage, url: URL, devices: [Device] = [], fileManager: FileManager = FileManager.default) {
//        self.id = id
//        self.image = image
//        self.url = url
//        self.devices = Set<Device>(devices)
//        self.fileManager = fileManager
//        self.contents = SessionContents(
//            id: id,
//            dateCreated: Date(),
//            lastModified: Date(),
//            devices: self.devices,
//            appIconSet: AppIconSet(assets: devices.reduce([], { $0 + $1.assets }))
//        )
//    }
//
    static var all: [Session] {
        return []
    }
    
    func delete() {
        
    }
    
    func save() throws {
        
    }
}
