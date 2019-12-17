//
//  Links.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/17/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import UIKit

enum Link: String {
    case appIconHIG = "https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/app-icon/"
    
    var url: URL? { URL(string: rawValue) }
}

struct Links {
    static func open(link: Link, completion: ((Bool) -> ())? = nil) {
        guard let url = link.url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
