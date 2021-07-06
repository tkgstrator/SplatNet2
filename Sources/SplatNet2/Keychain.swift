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
    class func setValue(value: Data?, forKey: String) -> Void {
        if let value = value {
            try? keychain.set(value, key: forKey)
        }
    }
    
    // UserInfoをDate型に変換して保存
    class func setValue(account: UserInfo) -> Void {
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
    
    // Coop情報を更新
    // こんな書き方しかないのかな...
    class func update(summary: Response.SummaryCoop) -> Void {
        var account = Keychain.account
        account.coop = UserInfo.CoopInfo(from: summary)
        setValue(account: account)
    }
    
    // Data型のデータを取得
    class func getValue(forKey: String) throws -> Data? {
        return try keychain.getData(forKey)
    }
    
    class var account: UserInfo {
        if let activeId = activeId {
            return getValue(nsaid: activeId)
        } else {
            return UserInfo()
        }
    }
    
    // 有効化されているアカウントの情報を保存
    class var activeId: String? {
        get {
            // 有効可されているアカウントがあればそのIDを返す
            if let activeId = try? keychain.get("activeId") {
                return activeId
            }
            // なければ全てのアカウントから先頭のものを返す
            return Keychain.getAllAccounts().first?.nsaid
        }
        set {
            if let newValue = newValue {
                try? keychain.set(newValue, key: "activeId")
            }
        }
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
        return Set(keychain.allKeys()).map({ $0 }).filter({ $0.count == 16 }).map({ getValue(nsaid: $0) })
    }
    
    class func deleteAllAccounts() -> Void {
        let keychains = keychain.allItems()
        for keychain in keychains {
            let server = keychain["server"] as! String
            let key = keychain["key"]
            
            if let url = URL(string: server) {
                let keychain = Keychain(server: url, protocolType: .https)
                keychain[key as! String] = nil
            } else {
                let keychain = Keychain(server: "work.tkgstrator", protocolType: .https)
                keychain[key as! String] = nil
            }
        }
    }
    
    func remove(forKey: String) -> Void {
        try? remove(forKey)
    }
}
