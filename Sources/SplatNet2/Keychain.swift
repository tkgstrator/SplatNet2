//
//  Keychain.swift
//  
//
//  Created by devonly on 2021/05/01.
//

import Foundation
import KeychainAccess

var keychain: Keychain {
    let server = "tkgstrator.work"
    return Keychain(server: server, protocolType: .https)
}

enum KeyType: String, CaseIterable {
    case playerId
    case iksmSession
    case sessionToken
    case version
}

extension Keychain {
    func setValue(value: String, forKey: KeyType) {
        try? keychain.set(value, key: forKey.rawValue)
    }
    
    func getValue(forKey: KeyType) -> String? {
        return try? keychain.get(forKey.rawValue)
    }

    func remove(forKey: KeyType) {
        try? keychain.remove(forKey.rawValue)
    }
}
