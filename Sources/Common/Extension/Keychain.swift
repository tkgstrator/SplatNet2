//
//  Keychain.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/05/01.
//  Copyright © 2021 Magi, Corporation. All rights reserved.

import Foundation
import KeychainAccess

public extension Keychain {
    /// Account
    var scheme: String { "SplatNet2" }
    /// Default
    var defaultScheme: String { "Default" }
    /// X-Product Version
    var version: String { "X-ProductVersion" }
    /// Refreshable
    var refreshable: String { "Refreshable" }
    /// JSONEncoder
    var encoder: JSONEncoder { JSONEncoder() }
    /// JSONDecoder
    var decoder: JSONDecoder { JSONDecoder() }

    /// X-Product Versionを取得
    func getVersion() -> String {
        guard let version = try? get(self.version) else {
            return "2.0.0"
        }
        return version
    }

    /// X-Product Versionを設定
    func setVersion(version: String?) {
        if let version = version {
            try? set(version, key: self.version)
        }
    }

    /// アカウントを取得
    func getAccounts() -> [UserInfo] {
        guard let data = try? getData(self.scheme),
              let accounts = try? decoder.decode([UserInfo].self, from: data)
        else {
            return [UserInfo]()
        }
        /// ダミーアカウント以外を返す
        return accounts.filter({ $0.friendCode != "XXXX-XXXX-XXXX" })
    }

    private func setAccounts(_ accounts: [UserInfo]) {
        guard let data = try? encoder.encode(accounts) else {
            return
        }
        try? set(data, key: self.scheme)
    }

    /// アカウントを取得
    func getAccount() -> UserInfo {
        guard let data = try? getData(self.defaultScheme),
              let account = try? decoder.decode(UserInfo.self, from: data)
        else {
            return UserInfo()
        }
        return account
    }
    
    /// デフォルトアカウントに設定
    func setAsDefault(_ account: UserInfo) {
        guard let data = try? encoder.encode(account) else {
            return
        }
        try? set(data, key: self.defaultScheme)
    }

    /// アカウントを追加
    func addAccount(_ account: UserInfo) {
        // 重複したデータをアップデート
        var accounts: Set<UserInfo> = Set(self.getAccounts())
        accounts.update(with: account)
        self.setAccounts(Array(accounts))
        // 追加したアカウントをデフォルトにする
        self.setAsDefault(account)
    }

    /// アカウントの並び替え
    func move(from source: IndexSet, to destination: Int) {
        var accounts: [UserInfo] = getAccounts()
        accounts.move(fromOffsets: source, toOffset: destination)
        self.setAccounts(accounts)
    }

    /// アカウントの削除
    func delete(at offsets: IndexSet) {
        var accounts: [UserInfo] = getAccounts()
        accounts.remove(atOffsets: offsets)
        self.setAccounts(accounts)
    }
}
