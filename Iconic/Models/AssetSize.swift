//
//  AssetSize.swift
//  Iconic
//
//  Created by Mohssen Fathi on 11/25/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import UIKit

protocol AssetProvider {
    var assets: [IconAsset] { get }
}

enum AssetType: String, Codable, CustomStringConvertible {
    case appStore = "App Store"
    
    case iPhoneNotifications = "iPhone Notifications"
    case iPhoneSettings = "iPhone Settings"
    case iPhoneSpotlight = "iPhone Spotlight"
    case iPhoneApp = "iPhone App"
    
    case iPadNotifications = "iPad Notifications"
    case iPadSettings = "iPad Settings"
    case iPadSpotlight = "iPad Spotlight"
    case iPadApp = "iPad App"
    case iPadProApp = "iPad Pro App"
    
    //    case appleWatchNotifications
    //    case appleWatchCompanionNotifications
    //    case appleWatchHomeScreen
    //    case appleWatchShortLook
        
    case carPlay
    
    var description: String { rawValue }
    
    var idiom: String {
        switch self {
        case .appStore:
            return "ios-marketing"
        case .carPlay:
            return ""
        case .iPadApp, .iPadNotifications, .iPadProApp, .iPadSettings, .iPadSpotlight:
            return "ipad"
        case .iPhoneApp, .iPhoneNotifications, .iPhoneSettings, .iPhoneSpotlight:
            return "iphone"
        }
    }
    
    var device: Device {
        switch self {
        case .appStore:
            return .appStore
        case .carPlay:
            return .unknown
        case .iPadApp, .iPadNotifications, .iPadProApp, .iPadSettings, .iPadSpotlight:
            return .iPad
        case .iPhoneApp, .iPhoneNotifications, .iPhoneSettings, .iPhoneSpotlight:
            return .iPhone
        }
    }
    
    var size: CGSize {
        switch self {
        case .appStore:
            return CGSize(width: 1024, height: 1024)
        case .iPhoneNotifications, .iPadNotifications:
            return CGSize(width: 20, height: 20)
        case .iPhoneSettings, .iPadSettings:
            return CGSize(width: 29, height: 29)
        case .iPhoneSpotlight, .iPadSpotlight:
            return CGSize(width: 40, height: 40)
        case .iPhoneApp, .carPlay:
            return CGSize(width: 60, height: 60)
        case .iPadApp:
            return CGSize(width: 76, height: 76)
        case .iPadProApp:
            return CGSize(width: 83.5, height: 83.5)
        }
    }
    
}

struct IconAsset: Codable, CustomStringConvertible, Identifiable {
    
    var id: String { return filename }
    let assetType: AssetType
    let scale: CGFloat
    
    var size: CGSize {
        assetType.size * scale
    }
    
    var sizeString: String {
        "\(size.width.removingZeroes())x\(size.height.removingZeroes())"
    }

    /// Unscaled size in format WxH
    var originalSizeString: String {
        "\(assetType.size.width.removingZeroes())x\(assetType.size.height.removingZeroes())"
    }
     
    var scaleString: String {
        "\(Int(scale))x"
    }
    
    var filename: String {
        return "AppIcon-\(originalSizeString)@\(scaleString).png"
    }
    
    var description: String {
        "\(assetType) - \(originalSizeString) @ \(scaleString)"
    }
}

extension CGSize {
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}

extension CGFloat {
    func removingZeroes() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: Double(self))
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        return String(formatter.string(from: number) ?? "")
    }
}
