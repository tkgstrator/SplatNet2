//
//  SplatNet2.swift
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

open class SplatNet2: ObservableObject {
    /// アクセス用のセッション
    internal let session: Session = {
        let configuration: URLSessionConfiguration = {
            let config = URLSessionConfiguration.default
            config.httpMaximumConnectionsPerHost = 1
            config.timeoutIntervalForRequest = 30
            return config
        }()
        return Session(configuration: configuration)
    }()

    /// ユーザデータを格納するKeychain
    // swiftlint:disable:next force_unwrapping
    public private(set) var keychain = Keychain(service: Bundle.main.bundleIdentifier!)

    /// X-ProductVersion
    public internal(set) var version: String {
        get {
            keychain.getVersion()
        }
        set {
            keychain.setVersion(version: newValue)
        }
    }

    // JSON Decoder
    internal let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// タスク管理
    public var task = Set<AnyCancellable>()

    /// 現在利用しているアカウント
    @Published public var account: UserInfo? {
        // バイト情報が更新されたらここが通知される
        // そのときにKeychainに最新のデータを入れる
        didSet {
            if let account = account {
                try? keychain.setValue(account)
            }
        }
    }

    /// 保存されている全てのアカウント
    @Published public internal(set) var accounts: [UserInfo] {
        willSet {
            try? keychain.setValue(newValue)
            account = newValue.first
        }
    }

    /// ユーザーエージェント
    internal let userAgent: String

    // イニシャライザ
    public init(userAgent: String) {
        self.userAgent = userAgent
        let accounts: [UserInfo] = keychain.getValue()
        self.accounts = accounts
        self.account = accounts.first
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
