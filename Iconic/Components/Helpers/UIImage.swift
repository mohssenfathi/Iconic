//
//  UIImage.swift
//  Iconic
//
//  Created by Mohssen Fathi on 11/26/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import UIKit

extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    func resize(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func cropped(to rect: CGRect) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { (context) in
            draw(at: rect.origin)
        }
    }
    
    func fill(size: CGSize) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        let scaledSize: CGSize
        let origin: CGPoint
        
        if aspectRatio > 1.0 {
            // Landscape
            // Scale smaller side (height) to full height
            // Scale larger side (width) to [aspectRatio * full height], so that it can be cropped in the next step
            scaledSize = CGSize(width: size.height * aspectRatio, height: size.height)
            
            // Origin is set to extended width / 2 for each edge
            origin = CGPoint(x: -(scaledSize.width - size.width) / 2.0, y: 0)
        } else {
            // Portrait
            // Scale smaller side (width) to full width
            // Scale larger side (height) to [aspectRatio * full width], so that it can be cropped in the next step
            scaledSize = CGSize(width: size.width, height: size.width / aspectRatio)
            
            // Origin is set to extended height / 2 for each edge
            origin = CGPoint(x: 0, y: -(scaledSize.height - size.height) / 2.0)
        }
        
        return resize(to: scaledSize)?.cropped(to: CGRect(origin: origin, size: size))
    }
    
    var isDark: Bool {
        return self.cgImage?.isDark ?? false
    }
}

extension CGImage {
    var isDark: Bool {
        get {
            guard let imageData = self.dataProvider?.data else { return false }
            guard let ptr = CFDataGetBytePtr(imageData) else { return false }
            let length = CFDataGetLength(imageData)
            let threshold = Int(Double(self.width * self.height) * 0.45)
            var darkPixels = 0
            for i in stride(from: 0, to: length, by: 4) {
                let r = ptr[i]
                let g = ptr[i + 1]
                let b = ptr[i + 2]
                let luminance = (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                if luminance < 150 {
                    darkPixels += 1
                    if darkPixels > threshold {
                        return true
                    }
                }
            }
            return false
        }
    }
}

