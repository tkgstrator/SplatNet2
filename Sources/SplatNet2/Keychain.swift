//
//  Keychain.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/05/01.
//

import Foundation
import KeychainAccess

public extension Keychain {
    func setValue(_ account: UserInfo) {
        let service: String = account.nsaid
        let keychain = Keychain(service: service)
        let encoder = JSONEncoder()
        guard let account = try? encoder.encode(account) else { return }
        try? keychain.set(account, key: service)
    }
    
    func getValue() -> UserInfo? {
        let decoder = JSONDecoder()
        guard let account = try? getData(self.service) else { return nil }
        return try? decoder.decode(UserInfo.self, from: account)
    }
}
