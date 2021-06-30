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
    
    func setValue(account: Response.UserInfo) {
        let encoder: JSONEncoder = JSONEncoder()
        let data = try? encoder.encode(account)
        setValue(value: data, forKey: account.nsaid)
    }
    
    func getValue(forKey: String) -> String? {
        return try? get(forKey)
    }
    
    func getValue(forKey: String) throws -> Data? {
        return try getData(forKey)
    }
    
    func getValue(nsaid: String) throws -> Response.UserInfo {
        print(nsaid)
        let decoder: JSONDecoder = JSONDecoder()
        guard let data: Data = try getValue(forKey: nsaid) else { fatalError() }
        return try decoder.decode(Response.UserInfo.self, from: data)
    }
    
    func getAccounts() throws -> [Response.UserInfo] {
        return try Set(Keychain.allKeys(.genericPassword).map({ $0.0 }).filter({ $0.count == 16 })).map({ try getValue(nsaid: $0) })
    }

    func remove(forKey: String) {
        try? remove(forKey)
    }
}
