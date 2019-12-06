//
//  AppIconSet.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/3/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import SwiftUI

struct AppIconSet: Codable {
    let contents: Contents
    let assets: [IconAsset]
    var url: URL?
    var images: [Contents.Image] {
        return contents.images
    }
    
    init(assets: [IconAsset]) {
        self.assets = assets
        self.contents = Contents(images: assets.map {
            Contents.Image(
                idiom: $0.assetType.idiom,
                size: $0.originalSizeString,
                scale: $0.scaleString,
                filename: $0.filename
            )
        })
    }
    
    struct Contents: Codable {
        let images: [Image]
        let info: Info
        
        init(images: [Image]) {
            self.images = images
            self.info = Info(version: 1, author: "Iconic")
        }
        
        struct Image: Codable {
            let idiom: String
            let size: String
            let scale: String
            let filename: String
        }
        
        struct Info: Codable {
            let version: Int
            let author: String
        }
    }

}
