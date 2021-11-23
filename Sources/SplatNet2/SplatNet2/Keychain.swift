//
//  Keychain.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/05/01.
//  Copyright © 2021 Magi, Corporation. All rights reserved.

import Foundation
import KeychainAccess

public extension Keychain {
    internal enum Service: String {
        case splatnet2 = "SplatNet2"
        case userinfo = "UserInfo"
    }

    internal convenience init(service: Service) {
        self.init(service: service.rawValue)
    }

    internal func getData() throws -> Data? {
        try getData(Service.userinfo.rawValue)
    }

    /// 自動でキーを設定して書き換え
    private func setValue(_ value: Data) throws {
        try set(value, key: Service.userinfo.rawValue)
    }

    /// バージョン情報のみを更新
    func setVersion(_ version: String) throws {
        let encoder = JSONEncoder()

        do {
            // Keychainからデータを取得
            let userdata = try getValue()
            // アカウントを上書き
            userdata.version = version
            // JSONEncoderでDataに変換
            let data = try encoder.encode(userdata)
            // Keychainに書き込み
            try setValue(data)
        } catch {
        }
    }

    /// アカウントの並びを変更
    func setValue(_ accounts: [UserInfo]) throws {
        let encoder = JSONEncoder()

        do {
            // Keychainからデータを取得
            let userdata = try getValue()
            // アカウントを上書き
            userdata.accounts = accounts
            // JSONEncoderでDataに変換
            let data = try encoder.encode(userdata)
            // Keychainに書き込み
            try setValue(data)
        } catch {
        }
    }

    /// アカウント追加(重複していた場合はアップデート)
    func setValue(_ account: UserInfo) throws {
        let encoder = JSONEncoder()

        do {
            // アカウント登録済みの場合(二重ログインのようなケース)
            // 現在登録されているデータを取得
            let userdata = try getValue()
            // 重複しているアカウントを削除して新たなデータで上書き
            let accounts = Array(userdata.accounts.drop(while: { $0.nsaid == account.nsaid || $0.nsaid == "0000000000000000" })) + [account]
            // アカウントを書き換え
            userdata.accounts = accounts
            // JSONEncoderでDataに変換
            let data = try encoder.encode(userdata)
            // Keychainに書き込み
            try setValue(data)
        } catch {
            // 初回登録のとき
            // ユーザアクセスデータを作成
            let userdata = UserAccess(accounts: [account])
            // JSONEncoderでDataに変換
            let data = try encoder.encode(userdata)
            // Keychainに書き込み
            try setValue(data)
        }
    }

    func getAccounts() -> [UserInfo] {
        guard let userdata = try? getValue() else {
            return [UserInfo(nsaid: "0000000000000000", nickname: "SplatNet2")]
        }
        return userdata.accounts.filter({ $0.nsaid != "0000000000000000" })
    }

    /// データ取得
    func getValue() throws -> UserAccess {
        let decoder = JSONDecoder()
        guard let account = try getData() else {
            throw SP2Error.OAuth(.response, nil)
        }
        return try decoder.decode(UserAccess.self, from: account)
    }
}
