//
//  LocalStore.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/3/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import Foundation

struct Defaults {
    @CodableUserDefault(key: "iconic_sessions", defaultValue: [])
    static var sessions: [SessionReference]
}

@propertyWrapper
struct CodableUserDefault<T: Codable> {
 
    let key: String
    let defaultValue: T
    private let decoder = PropertyListDecoder()
    private let encoder = PropertyListEncoder()
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.value(forKey: key) as? Data else {
                return defaultValue
            }
            return (try? decoder.decode(T.self, from: data)) ?? defaultValue
        }
        set {
            guard let data = try? encoder.encode(newValue) else {
                return
            }
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}
