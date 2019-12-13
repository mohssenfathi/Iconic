//
//  HiddenModifier.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/10/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    /// Whether the view is hidden.
    /// - Parameter bool: Set to `true` to hide the view. Set to `false` to show the view.
    func isHidden(_ bool: Bool) -> some View {
        modifier(HiddenModifier(isHidden: bool))
    }
}


/// Creates a view modifier that can be applied, like so:
///
///
/// ```
/// Text("Hello World!")
///     .isHidden(true)
/// ```
///
/// Variables can be used in place so that the content can be changed dynamically.
private struct HiddenModifier: ViewModifier {
    
    fileprivate let isHidden: Bool
    
    fileprivate func body(content: Content) -> some View {
        Group {
            if isHidden {
                content.hidden()
            } else {
                content
            }
        }
    }
}
