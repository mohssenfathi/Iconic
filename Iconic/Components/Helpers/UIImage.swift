//
//  UIImage.swift
//  Iconic
//
//  Created by Mohssen Fathi on 11/26/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import UIKit

extension UIImage {
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
}
