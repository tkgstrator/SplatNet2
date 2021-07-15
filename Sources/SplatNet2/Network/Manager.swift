//
//  Manager.swift
//  SplatNet2
//
//  Created by devonly on 2021/07/13.
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
    public static let dispatchQueue = DispatchQueue(label: "Network Publisher")
    public static let semaphore = DispatchSemaphore(value: 0)
    
    // JSON Encoder
    private var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    public var task = Set<AnyCancellable>()
    internal var keychain: Keychain = Keychain(service: "SplatNet2")
    // プレイヤーIDを切り替えるとKeychainが切り替わる
    internal var playerId: String {
        get {
            keychain.getValue()?.nsaid ?? ""
        }
        set {
            keychain = Keychain(service: newValue)
        }
    }
    internal let userAgent: String
    internal let version: String = "1.11.0"
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
    
    // イニシャライザ
    public init(userAgent: String) {
        self.userAgent = userAgent
    }
    
    internal var iksmSession: String {
        SplatNet2.account.iksmSession
    }
    
    internal var sessionToken: String {
        SplatNet2.account.sessionToken
    }
    
    public class var account: UserInfo {
        SplatNet2.getAllAccounts().first ?? UserInfo()
    }
    
    public class func getAllAccounts() -> [UserInfo] {
        print(Keychain.allItems(.genericPassword))
        let account = Keychain.allItems(.genericPassword)
            .compactMap({ $0["service"] as? String })
            .filter({ $0.count == 16 })
            .compactMap({ Keychain(service: $0).getValue() })
        print(account)
        return []
    }
    
    public class func deleteAllAccounts() {
        let services: [String] = Keychain.allItems(.genericPassword)
            .compactMap({ $0["service"] as? String })
//            .filter({ $0.count == 16 })
        for service in services {
            let keychain = Keychain(service: service)
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
