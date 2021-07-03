//
//  Keychain.swift
//  
//
//  Created by devonly on 2021/05/01.
//

import Foundation
import KeychainAccess

extension Keychain {
    
    func setValue(value: String?, forKey: String) {
        if let value = value {
            try? set(value, key: forKey)
        }
    }
    
    func setValue(value: Data?, forKey: String) {
        if let value = value {
            try? set(value, key: forKey)
        }
    }
    
    func setValue(account: UserInfo) {
        let encoder: JSONEncoder = JSONEncoder()
        let data = try? encoder.encode(account)
        if !account.nsaid.isEmpty {
            setValue(value: data, forKey: account.nsaid)
        }
    }
    
    func getValue(forKey: String) -> String? {
        return try? get(forKey)
    }
    
    func getValue(forKey: String) throws -> Data? {
        return try getData(forKey)
    }
    
    func getValue(nsaid: String) throws -> UserInfo {
        let decoder: JSONDecoder = JSONDecoder()
        guard let data: Data = try getValue(forKey: nsaid) else { throw APIError.invalidAccount }
        return try decoder.decode(UserInfo.self, from: data)
    }
    
    static func getAccounts() throws -> [UserInfo] {
        let keychain = Keychain(server: URL(string: "https://tkgstrator.work")!, protocolType: .https)
        return try Set(keychain.allKeys()).map({ $0 }).map({ try keychain.getValue(nsaid: $0) })
    }

    func remove(forKey: String) {
        try? remove(forKey)
    }
}
