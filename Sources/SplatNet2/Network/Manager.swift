import Foundation
import Alamofire
import Combine
import CryptoKit
import KeychainAccess

final public class SplatNet2 {
    // State, Verifier
    #if DEBUG
    private let state = "v1MguHzdCzhY7W7DMciwfFGPbzV0qdukFOnPX6czsT7m2END726qGJRrScHUT5AmZ2oS7RArsVj2z4eDH4BqThJpvQv7rgLIrHSOzp4NtwS3kFG3kIOqSE4vHCDUYE0X"
    private let verifier = "VVSJwmWlQonJu047zDA2jgUtyuK3taxUV8tmUyQnpxLk4Q1ZBAUNvb6d1QPbyOKVbhKtr2IowR92oNP0eXCJvEWQkjeAB0WK7Klca2IjEyJvMVns2pn12UaJPquX9DKg"
    #else
    private let state = String.randomString
    private let verifier = String.randomString
    #endif
    
    // JSON Encoder
    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    internal var keychain: Keychain {
        if let service = service {
            return Keychain(service: service)
        } else {
            return Keychain()
        }
    }
    
    internal var service: String?
    
    // IksmSession
    public var iksmSession: String? {
        get {
            keychain.getValue(forKey: .iksmSession)
        }
        set {
            keychain.setValue(value: newValue, forKey: .iksmSession)
        }
    }
    
    // SessionToken
    public var sessionToken: String? {
        get {
            return keychain.getValue(forKey: .sessionToken)
        }
        set {
            keychain.setValue(value: newValue, forKey: .sessionToken)
        }
    }
    
    // nsaid
    public var playerId: String? {
        get {
            keychain.getValue(forKey: .playerId)
        }
        set {
            keychain.setValue(value: newValue, forKey: .playerId)
        }
    }
    
    // Version
    public var version: String {
        get {
            keychain.getValue(forKey: .version) ?? "1.11.0"
        }
        set {
            keychain.setValue(value: newValue, forKey: .version)
        }
    }
    
    public static var shared: SplatNet2 {
        let services = Keychain.allItems(.genericPassword)
        if let service = services.first?["service"] as? String {
            return SplatNet2(nsaid: service)
        } else {
            return SplatNet2()
        }
    }
    
    internal var task = Set<AnyCancellable>()
    
    // 複数アカウント対応
    public init(nsaid service: String? = nil) {
        self.service = service
    }
    
    public init(nsaid service: String? = nil, iksmSession: String) {
        self.service = service
        self.iksmSession = iksmSession
    }

    public var oauthURL: URL {
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
    
    // ローカルファイルを参照しているだけなのでエラーが発生するはずがない
    @discardableResult
    public func getShiftSchedule() -> Future<[Response.ScheduleCoop], Error> {
        return Future { promise in
            if let json = Bundle.module.url(forResource: "coop", withExtension: "json") {
                if let data = try? Data(contentsOf: json) {
                    let decoder: JSONDecoder = {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        return decoder
                    }()
                    
                    if let shift = try? decoder.decode([Response.ScheduleCoop].self, from: data) {
                        promise(.success(shift))
                    } else {
                        promise(.failure(APIError.unknown))
                    }
                } else {
                    promise(.failure(APIError.unknown))
                }
            } else {
                promise(.failure(APIError.unknown))
            }
        }
    }

    //
    @discardableResult
    public func getSessionToken(sessionTokenCode: String) -> Future<Response.SessionToken, Error> {
        let request = SessionToken(code: sessionTokenCode, verifier: verifier)
        return remote(request: request)
    }
    
    @discardableResult
    func getAccessToken() -> Future<Response.AccessToken, Error> {
        let request = AccessToken(sessionToken: sessionToken)
        return remote(request: request)
    }
    
    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    func getSplatoonToken(accessToken: String) -> Future<Response.SplatoonToken, Error> {
        Future { [self] promise in
            getParameterF(accessToken: accessToken, type: false)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    // Flapg API
                    let request = SplatoonToken(from: response, version: version)
                    remote(request: request)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }, receiveValue: { response in
                            promise(.success(response))
                        })
                        .store(in: &task)
                })
                .store(in: &task)
        }
    }
    
    // Splatoon Access Token
    @discardableResult
    func getSplatoonAccessToken(splatoonToken: String) -> Future<Response.SplatoonAccessToken, Error> {
        Future { [self] promise in
            getParameterF(accessToken: splatoonToken, type: true)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    let request = SplatoonAccessToken(from: response, splatoonToken: splatoonToken, version: version)
                    remote(request: request)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }, receiveValue: { response in
                            promise(.success(response))
                        })
                        .store(in: &task)
                })
                .store(in: &task)
        }
    }
    
    // Iksm Session
    @discardableResult
    func getIksmSession(accessToken: String) -> Future<Response.IksmSession, Error> {
        let request = IksmSession(accessToken: accessToken)
        return generate(request: request)
    }
    
    // Parameter F
    @discardableResult
    func getParameterF(accessToken: String, type: Bool) -> Future<Response.FlapgAPI, Error> {
        let timestamp = Int(Date().timeIntervalSince1970)
        let request = S2SHash(accessToken: accessToken, timestamp: timestamp)
        
        return Future { [self] promise in
            remote(request: request)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { (response: Response.S2SHash) in
                    let request = FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
                    remote(request: request)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }, receiveValue: { (response: Response.FlapgAPI) in
                            promise(.success(response))
                        })
                        .store(in: &task)
                })
                .store(in: &task)
        }
    }
    
//    @discardableResult
//    public func convertResultWithJSONFormat(results: [Coop.Result]) -> [String] {
//        return results.map{ String(data: try! encoder.encode($0), encoding: .utf8)! }
//    }
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
