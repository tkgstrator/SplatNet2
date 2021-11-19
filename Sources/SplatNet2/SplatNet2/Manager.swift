//
//  Manager.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Combine
import CryptoKit
import Foundation
import KeychainAccess

open class SplatNet2 {
    /// アクセス用のセッション
    internal let session: Session
    // JSON Encoder
    internal var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    // JSON Decoder
    internal let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// タスク管理
    public var task = Set<AnyCancellable>()
    /// ユーザデータを格納するKeychain
    public private(set) var keychain = Keychain(service: .splatnet2)
    /// 現在利用しているアカウント
    public internal(set) var account: UserInfo {
        willSet {
            // アカウントを上書きするとその値をKeychainに書き込む
            try? keychain.setValue(newValue)
        }
    }
    /// 保存されている全てのアカウント
    public var accounts: [UserInfo] {
        guard let userdata = try? keychain.getValue() else {
            return []
        }
        return userdata.accounts
    }
    /// ユーザーエージェント
    internal let userAgent: String
    /// X-Product Version
    public internal(set) var version: String {
        willSet {
            try? keychain.setVersion(newValue)
        }
    }

    // イニシャライザ
    public init(version: String = "1.13.2") {
        session = {
            let configuration: URLSessionConfiguration = {
                let config = URLSessionConfiguration.default
                config.httpMaximumConnectionsPerHost = 1
                config.timeoutIntervalForRequest = 30
                return config
            }()
            return Session(configuration: configuration, serializationQueue: DispatchQueue(label: "SplatNet2"))
        }()

        do {
            // Keychainからバージョン情報を取得する
            let userdata: UserAccess = try keychain.getValue()
            self.version = userdata.version
            self.userAgent = "SplatNet2/@tkgling"
            // 保存されているアカウントから最も新しいものを選択
            if let account = userdata.accounts.first {
                self.account = account
            } else {
                // 存在しない場合は仮のデータで埋める
                self.account = UserInfo(nsaid: "0000000000000000", nickname: "Unregistered")
            }
        } catch {
            // アカウント情報が得られないとき
            self.version = version
            self.userAgent = "SplatNet2/@tkgling"
            self.account = UserInfo(nsaid: "0000000000000000", nickname: "Unregistered")
        }
    }

    internal var iksmSession: String {
        #if DEBUG
        return account.iksmSession
        #else
        return account.iksmSession
        #endif
    }

    internal var sessionToken: String {
        account.sessionToken
    }

    internal func oauthURL(state: String, verifier: String) -> URL {
        let parameters: [String: String] = [
            "state": state,
            "redirect_uri": "npf71b963c1b7b6d119://auth",
            "client_id": "71b963c1b7b6d119",
            "scope": "openid+user+user.birthday+user.mii+user.screenName",
            "response_type": "session_token_code",
            "session_token_code_challenge": verifier.codeChallenge,
            "session_token_code_challenge_method": "S256",
            "theme": "login_form",
        ]
        return URL(unsafeString: "https://accounts.nintendo.com/connect/1.0.0/authorize?\(parameters.queryString)")
    }
}

extension String {
    public static var randomString: String {
        let letters: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        // swiftlint:disable:next force_unwrapping
        return String((0 ..< 128).map({ _ in letters.randomElement()! }))
    }

    var base64EncodedString: String {
        // swiftlint:disable:next force_unwrapping
        self.data(using: .utf8)!
            .base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }

    var codeChallenge: String {
        Data(SHA256.hash(data: Data(self.utf8))).base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }
}

extension Dictionary where Key == String, Value == String {
    var queryString: String {
        self.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }
}