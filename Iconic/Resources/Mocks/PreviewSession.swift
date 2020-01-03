//
//  TestSession.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/20/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import UIKit

class PreviewSession: Session {
    
    init() {
        try! super.init(identifier: UUID().uuidString, image: #imageLiteral(resourceName: "87DDE083-4EA3-48F8-AC24-259F0E351C5B.png"))
    }
}
