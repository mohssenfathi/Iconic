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
    
//    case appleTV = "Apple TV"
    case appleWatch = "Apple Watch"
    case carPlay = "CarPlay"
    case iPad
    case iPhone
    case mac = "Mac"
    case appStore = "App Store"
    case unknown = "Unknown"
    
    var id: String {
        return rawValue
    }
    
    var image: Image {
        switch self {
        case .appleWatch: return Image("apple-watch")
        case .carPlay: return Image("CarPlay")
        case .mac: return Image("Mac")
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
        case .appleWatch:
            return [
                IconAsset(assetType: .appleWatchNotificationCenter38, scale: 2),
                IconAsset(assetType: .appleWatchNotificationCenter40, scale: 2),
                IconAsset(assetType: .appleWatchCompanionSettings, scale: 2),
                IconAsset(assetType: .appleWatchCompanionSettings, scale: 3),
                IconAsset(assetType: .appleWatchHomeScreen38, scale: 2),
                IconAsset(assetType: .appleWatchHomeScreen40, scale: 2),
                IconAsset(assetType: .appleWatchHomeScreen44, scale: 2),
                IconAsset(assetType: .appleWatchShortLook38, scale: 2),
                IconAsset(assetType: .appleWatchShortLook40, scale: 2),
                IconAsset(assetType: .appleWatchShortLook44, scale: 2),
                IconAsset(assetType: .appleWatchAppStore, scale: 1)
            ]
        case .carPlay:
            return []
        case .mac:
            return [
                IconAsset(assetType: .macSmall, scale: 1),
                IconAsset(assetType: .macSmall, scale: 2),
                IconAsset(assetType: .macMedium, scale: 1),
                IconAsset(assetType: .macMedium, scale: 2),
                IconAsset(assetType: .macLarge, scale: 1),
                IconAsset(assetType: .macLarge, scale: 2),
                IconAsset(assetType: .macXLarge, scale: 1),
                IconAsset(assetType: .macXLarge, scale: 2),
                IconAsset(assetType: .macXXLarge, scale: 1),
                IconAsset(assetType: .macXXLarge, scale: 2)
            ]
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

