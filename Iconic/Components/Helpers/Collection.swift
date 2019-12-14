//
//  Collection.swift
//  Iconic
//
//  Created by Mohssen Fathi on 11/26/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation

public extension Collection {
    func grouped<T>(by keyPath: KeyPath<Element, T>) -> [T: [Element]] {
        var groups = [T: [Element]]()
        forEach {
            let key = $0[keyPath: keyPath]
            if groups[key] == nil {
                groups[key] = [$0]
            } else {
                groups[key]?.append($0)
            }
        }
        return groups
    }
    
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted {
            return $0[keyPath: keyPath] <= $1[keyPath: keyPath]
        }
    }
}
