//
//  Keychain.swift
//  
//
//  Created by devonly on 2021/05/01.
//

import Foundation
import KeychainAccess

extension Keychain {
    // 共通なので再利用可能にする
    static let keychain = Keychain(server: URL(string: "https://tkgstrator.work")!, protocolType: .https)

    // Data型を保存する
    class func setValue(value: Data?, forKey: String) {
        if let value = value {
            try? keychain.set(value, key: forKey)
        }
    }
    
    // UserInfoをDate型に変換して保存
    class func setValue(account: UserInfo) {
        let encoder: JSONEncoder = JSONEncoder()
        do {
            let data = try encoder.encode(account)
            // IDがからの場合はダミーデータなので保存しない
            if !account.nsaid.isEmpty {
                setValue(value: data, forKey: account.nsaid)
            }
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }
   
    // Data型のデータを取得
    class func getValue(forKey: String) throws -> Data? {
        return try keychain.getData(forKey)
    }
    
    // IDを指定してユーザ情報を取得
    // 該当IDがない場合はダミーデータを返す
    class func getValue(nsaid: String) -> UserInfo {
        let decoder: JSONDecoder = JSONDecoder()
        do {
            guard let data: Data = try getValue(forKey: nsaid) else { throw APIError.invalidAccount }
            return try decoder.decode(UserInfo.self, from: data)
        } catch {
            return UserInfo()
        }
    }
    
    // 全てのアカウントの情報を取得
    class func getAllAccounts() -> [UserInfo] {
        let keychain = Keychain(server: URL(string: "https://tkgstrator.work")!, protocolType: .https)
        let accounts = Set(keychain.allKeys()).map({ $0 }).map({ getValue(nsaid: $0) })
        print(accounts.count)
        return accounts
    }

    func remove(forKey: String) {
        try? remove(forKey)
    }
}
