//
//  Device.swift
//  Iconic
//
//  Created by Mohssen Fathi on 11/24/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import SwiftUI

enum Device: String, CaseIterable, Identifiable, Codable {
    
    case appleTV = "Apple TV"
    case appleWatch = "Apple Watch"
    case iMac
    case iPad
    case iPhone
    case appStore = "App Store"
    case unknown = "Unknown"
    
    var id: String {
        return rawValue
    }
    
    var image: Image {
        switch self {
        case .appleTV: return Image("apple-tv")
        case .appleWatch: return Image("apple-watch")
        case .iMac: return Image("iMac")
        case .iPad: return Image("iPad")
        case .iPhone: return Image("iPhone")
        case .appStore, .unknown:
            return Image(systemName: "questionmark.circle")
        }
    }
    
    var title: String {
        return rawValue
    }
}

extension Device: AssetProvider {
    var assets: [IconAsset] {
        switch self {
        case .appleTV:
            return []
        case .appleWatch:
            return []
        case .iMac:
            return []
        case .iPad:
            return [
                IconAsset(assetType: .iPadNotifications, scale: 1),
                IconAsset(assetType: .iPadNotifications, scale: 2),
                IconAsset(assetType: .iPadSettings, scale: 1),
                IconAsset(assetType: .iPadSettings, scale: 2),
                IconAsset(assetType: .iPadSpotlight, scale: 1),
                IconAsset(assetType: .iPadSpotlight, scale: 2),
                IconAsset(assetType: .iPadApp, scale: 1),
                IconAsset(assetType: .iPadApp, scale: 2),
                IconAsset(assetType: .iPadProApp, scale: 2)
            ]
        case .iPhone:
            return [
                IconAsset(assetType: .iPhoneNotifications, scale: 2),
                IconAsset(assetType: .iPhoneNotifications, scale: 3),
                IconAsset(assetType: .iPhoneSettings, scale: 2),
                IconAsset(assetType: .iPhoneSettings, scale: 3),
                IconAsset(assetType: .iPhoneSpotlight, scale: 2),
                IconAsset(assetType: .iPhoneSpotlight, scale: 3),
                IconAsset(assetType: .iPhoneApp, scale: 2),
                IconAsset(assetType: .iPhoneApp, scale: 3)
            ]
        case .appStore:
            return [
                IconAsset(assetType: .appStore, scale: 1)
            ]
        case .unknown:
            return []
        }
    }
}

