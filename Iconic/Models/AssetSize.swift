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
    
    case macSmall = "macOS Small"
    case macMedium = "macOS Medium"
    case macLarge = "macOS Large"
    case macXLarge = "macOS Extra Large"
    case macXXLarge = "macOS Extra Extra Large"
    
    case appleWatchNotificationCenter38 = "Apple Watch Notification Center - 38mm"
    case appleWatchNotificationCenter40 = "Apple Watch Notification Center - 40mm + 42mm"
    case appleWatchCompanionSettings = "Apple Watch Companion Settings"
    case appleWatchHomeScreen38 = "Apple Watch Home Screen - 38mm"
    case appleWatchHomeScreen40 = "Apple Watch Home Screen - 40mm + 42mm"
    case appleWatchHomeScreen44 = "Apple Watch Home Screen - 44mm"
    case appleWatchShortLook38 = "Apple Watch Short Look - 38mm"
    case appleWatchShortLook40 = "Apple Watch Short Look - 40mm + 42mm"
    case appleWatchShortLook44 = "Apple Watch Short Look - 44mm"
    case appleWatchAppStore = "Apple Watch App Store"
        
    case carPlay
    
    var description: String { rawValue }
    
    var idiom: String {
        switch self {
        case .appStore:
            return "ios-marketing"
        case .appleWatchAppStore:
            return "watch-marketing"
        case .carPlay:
            return ""
        case .iPadApp, .iPadNotifications, .iPadProApp, .iPadSettings, .iPadSpotlight:
            return "ipad"
        case .iPhoneApp, .iPhoneNotifications, .iPhoneSettings, .iPhoneSpotlight:
            return "iphone"
        case .macSmall, .macMedium, .macLarge, .macXLarge, .macXXLarge:
            return "mac"
        case .appleWatchNotificationCenter38,  .appleWatchNotificationCenter40,  .appleWatchCompanionSettings,  .appleWatchHomeScreen38,  .appleWatchHomeScreen40,  .appleWatchHomeScreen44,  .appleWatchShortLook38,  .appleWatchShortLook40,  .appleWatchShortLook44:
            return "watch"
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
        case .macSmall, .macMedium, .macLarge, .macXLarge, .macXXLarge:
            return .mac
        case .appleWatchNotificationCenter38,  .appleWatchNotificationCenter40,  .appleWatchCompanionSettings,  .appleWatchHomeScreen38,  .appleWatchHomeScreen40,  .appleWatchHomeScreen44,  .appleWatchShortLook38,  .appleWatchShortLook40,  .appleWatchShortLook44, .appleWatchAppStore:
            return .appleWatch
        }
    }
    
    
    var role: String? {
        switch self {
        case .appleWatchNotificationCenter38,  .appleWatchNotificationCenter40:
            return "notificationCenter"
        case .appleWatchCompanionSettings:
            return "companionSettings"
        case .appleWatchHomeScreen38,  .appleWatchHomeScreen40,  .appleWatchHomeScreen44:
            return "appLauncher"
        case .appleWatchShortLook38,  .appleWatchShortLook40,  .appleWatchShortLook44:
            return "quickLook"
        default:
            return nil
        }
    }
    
    var subtype: String? {
        switch self {
        case .appleWatchNotificationCenter38, .appleWatchHomeScreen38, .appleWatchShortLook38:
            return "38mm"
        case .appleWatchHomeScreen40:
            return "40mm"
        case .appleWatchNotificationCenter40, .appleWatchShortLook40:
            return "42mm"
        case .appleWatchHomeScreen44, .appleWatchShortLook44:
            return "44mm"
        default:
            return nil
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
        case .macSmall:
            return CGSize(width: 16, height: 16)
        case .macMedium:
            return CGSize(width: 32, height: 32)
        case .macLarge:
            return CGSize(width: 128, height: 128)
        case .macXLarge:
            return CGSize(width: 256, height: 256)
        case .macXXLarge:
            return CGSize(width: 512, height: 512)
        case .appleWatchNotificationCenter38:
            return CGSize(width: 24, height: 24)
        case .appleWatchNotificationCenter40:
            return CGSize(width: 27.5, height: 27.5)
        case .appleWatchCompanionSettings:
            return CGSize(width: 29, height: 29)
        case .appleWatchHomeScreen38:
            return CGSize(width: 40, height: 40)
        case .appleWatchHomeScreen40:
            return CGSize(width: 44, height: 44)
        case .appleWatchHomeScreen44:
            return CGSize(width: 50, height: 50)
        case .appleWatchShortLook38:
            return CGSize(width: 86, height: 86)
        case .appleWatchShortLook40:
            return CGSize(width: 98, height: 98)
        case .appleWatchShortLook44:
            return CGSize(width: 108, height: 108)
        case .appleWatchAppStore:
            return CGSize(width: 1024, height: 1024)
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
    
    var role: String? {
        assetType.role
    }
    
    var subtype: String? {
        assetType.subtype
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
