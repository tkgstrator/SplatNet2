//
//  Keychain.swift
//  
//
//  Created by devonly on 2021/05/01.
//

import Foundation
import KeychainAccess

enum KeyType: String, CaseIterable {
    case playerId
    case iksmSession
    case sessionToken
    case version
}

extension Keychain {
    func setValue(value: String?, forKey: KeyType) {
        if let value = value {
            try? set(value, key: forKey.rawValue)
        }
    }
    
    func getValue(forKey: KeyType) -> String? {
        return try? get(forKey.rawValue)
    }

    func remove(forKey: KeyType) {
        try? remove(forKey.rawValue)
    }
}
