//
//  Keychain.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Foundation
import KeychainAccess

extension Keychain {
    /// APIToken
    var apiToken: String { "APIToken" }

    /// APITokenを取得
    func getAPIToken() -> String? {
        try? get(self.apiToken)
    }

    /// APITokenを設定
    func setAPIToken(apiToken: String?) {
        if let apiToken = apiToken {
            try? set(apiToken, key: self.apiToken)
        }
    }
}
