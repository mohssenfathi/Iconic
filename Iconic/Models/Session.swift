//
//  Session.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/3/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import UIKit

class Session: SessionProtocol, ObservableObject, Identifiable {
    
    var image: UIImage
    var contents: SessionContents
    let id: String
    let url: URL
    let fileManager: FileManager = FileManager.default
    
    var devices: Set<Device> {
        set { contents.devices = newValue }
        get { return Set<Device>(contents.devices) }
    }
    
    var title: String {
        set { contents.title = newValue }
        get { return contents.title }
    }
    
    init(identifier: String = UUID().uuidString,
         image: UIImage = UIImage(color: .white, size: CGSize(width: 1024, height: 1024)) ?? UIImage()) throws {
        self.id = identifier
        self.image = image
        self.contents = SessionContents(id: identifier)

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
}

extension Session: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SessionContents: Codable {
    let id: String
    var title: String
    let dateCreated: Date
    var lastModified: Date
    var devices: Set<Device> {
        didSet {  appIconSet = AppIconSet(assets: devices.reduce([], { $0 + $1.assets })) }
    }
    var appIconSet: AppIconSet
    
    public init(id: String = "", title: String = "My App Icon", dateCreated: Date = Date(), lastModified: Date = Date(), devices: Set<Device> = [], appIconSet: AppIconSet = AppIconSet(assets: [])) {
        self.id = id
        self.title = title
        self.dateCreated = dateCreated
        self.lastModified = lastModified
        self.devices = devices
        self.appIconSet = appIconSet
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
    case imageContainsTransparency
    case imageResize
    case notFound
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .imageTooSmall:
            return "Image too small. Input images must have a size of 1024px x 1024px or greater."
        case .imageContainsTransparency:
            return "Input images cannot have transparency."
        case .imageResize:
            return "There was an issue resizing the provided image."
        case .unknown:
            return "An unknown error occurred. Please try again."
        case .notFound:
            return "There was an issue importing the selected image. Please try again."
        }
    }
}


