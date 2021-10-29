//
//  Manager.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//

import Foundation
import Alamofire
import Combine
import CryptoKit
import KeychainAccess

open class SplatNet2: ObservableObject {
    
    // State, Verifier
    internal static let state = String.randomString
    internal static let verifier = String.randomString
    internal static let dispatchQueue: DispatchQueue = DispatchQueue(label: "Network Publisher")
    internal let dispatchQueue: DispatchQueue = DispatchQueue(label: "SplatNet2")
    public static let semaphore = DispatchSemaphore(value: 0)
    
    // JSON Encoder
    private var encoder: JSONEncoder = {
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
    
    public var task = Set<AnyCancellable>()
    internal var keychain: Keychain = Keychain(service: "SplatNet2")

    internal let userAgent: String
    internal let version: String
    internal static var oauthURL: URL {
        let parameters: [String: String] = [
            "state": state,
            "redirect_uri": "npf71b963c1b7b6d119://auth",
            "client_id": "71b963c1b7b6d119",
            "scope": "openid+user+user.birthday+user.mii+user.screenName",
            "response_type": "session_token_code",
            "session_token_code_challenge": verifier.codeChallenge,
            "session_token_code_challenge_method": "S256",
            "theme": "login_form"
        ]
        return URL(string: "https://accounts.nintendo.com/connect/1.0.0/authorize?\(parameters.queryString)")!
    }

    public var playerId: String {
        account.nsaid
    }
    
    internal var iksmSession: String {
        account.iksmSession
    }
    
    internal var sessionToken: String {
        account.sessionToken
    }
    
    public var account: UserInfo = UserInfo()
    
    // イニシャライザ
    public init(userAgent: String, version: String = "1.12.0") {
        self.userAgent = userAgent
        self.version = version
        if let account = getAllAccounts().first {
            self.account = account
        }
    }

    internal func addAccount(account: UserInfo) {
        keychain.setValue(account)
    }
    
    internal func getAllAccounts() -> [UserInfo] {
        return Keychain.allItems(.genericPassword)
            .compactMap({ $0["service"] as? String })
            .filter({ $0.count == 16 })
            .compactMap({ Keychain(service: $0).getValue() })
    }
    
    public func deleteAllAccounts() {
        let services: [String] = Keychain.allItems(.genericPassword)
            .compactMap({ $0["service"] as? String })
//            .filter({ $0.count == 16 })
        for service in services {
            print(service)
            let keychain = Keychain(service: service)
            try? keychain.removeAll()
        }
        let servers: [String] = Keychain.allItems(.internetPassword)
            .compactMap({ $0["server"] as? String })
//            .filter({ $0.count == 16 })
        for server in servers {
            print(server)
            let keychain = Keychain(server: server, protocolType: .https)
            try? keychain.removeAll()
        }
    }
}

extension String {
    static var randomString: String {
        let letters: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<128).map { _ in letters.randomElement()! })
    }
    
    var base64EncodedString: String {
        self.data(using: .utf8)!.base64EncodedString()
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
