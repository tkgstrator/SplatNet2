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
    var version: String { "X-Product Version" }
    /// JSONEncoder
    var encoder: JSONEncoder { JSONEncoder() }
    /// JSONDecoder
    var decoder: JSONDecoder { JSONDecoder() }

    /// X-Product Versionを取得
    func getVersion() -> String {
        guard let version = try? get(self.version) else {
            return "1.13.2"
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
    func getAllUserInfo() -> [UserInfo] {
        guard let data = try? getData(scheme),
              let accounts = try? decoder.decode([UserInfo].self, from: data)
        else {
            return [UserInfo]()
        }
        return accounts
    }

    /// デフォルトアカウントとしてセット
    func getUserInfo() -> UserInfo? {
        guard let data = try? getData(defaultScheme),
              let account = try? decoder.decode(UserInfo.self, from: data)
        else {
            return nil
        }
        return account
    }

    /// アカウントを追加
    func setUserInfo(_ account: UserInfo?) throws {
        guard let account = account else {
            return
        }
        try set(try encoder.encode(account), key: defaultScheme)
    }

    /// アカウントを追加
    func setUserInfo(_ accounts: [UserInfo]) throws {
        try set(try encoder.encode(accounts), key: scheme)
    }

    /// アカウントを追加
    func setUserInfo(_ account: UserInfo) throws {
        // 重複したデータをアップデート
        var accounts: Set<UserInfo> = Set(getAllUserInfo())
        accounts.update(with: account)
        try self.setUserInfo(Array(accounts))
    }

    /// アカウントの並び替え
    func move(from source: IndexSet, to destination: Int) throws {
        var accounts: [UserInfo] = getAllUserInfo()
        accounts.move(fromOffsets: source, toOffset: destination)
        try self.setUserInfo(accounts)
    }

    /// アカウントの削除
    func delete(at offsets: IndexSet) throws {
        var accounts: [UserInfo] = getAllUserInfo()
        accounts.remove(atOffsets: offsets)
        try self.setUserInfo(accounts)
    }
}
