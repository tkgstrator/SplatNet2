import Foundation
import Alamofire
import Combine
import CryptoKit
import KeychainAccess

open class SplatNet2 {
    
    // State, Verifier
    internal static let state = String.randomString
    internal static let verifier = String.randomString
    internal static let dispatchQueue = DispatchQueue(label: "Network Publisher")
    internal static let semaphore = DispatchSemaphore(value: 0)
    
    // JSON Encoder
    private var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    internal var task = Set<AnyCancellable>()

    // 常に最新のデータを取得
    public var account: UserInfo {
        Keychain.account
    }

    public var playerId: String {
        account.nsaid
    }

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
    
    public init() {}
    
    public class func deleteAllAccounts() -> Void {
        Keychain.deleteAllAccounts()
    }
    
    public class func getAllAccounts() -> [UserInfo] {
        Keychain.getAllAccounts()
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
