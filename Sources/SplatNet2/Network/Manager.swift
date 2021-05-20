import Foundation
import Alamofire
import Combine
import CryptoKit

final public class SplatNet2 {
    
    #if DEBUG
    private let state = "v1MguHzdCzhY7W7DMciwfFGPbzV0qdukFOnPX6czsT7m2END726qGJRrScHUT5AmZ2oS7RArsVj2z4eDH4BqThJpvQv7rgLIrHSOzp4NtwS3kFG3kIOqSE4vHCDUYE0X"
    private let verifier = "VVSJwmWlQonJu047zDA2jgUtyuK3taxUV8tmUyQnpxLk4Q1ZBAUNvb6d1QPbyOKVbhKtr2IowR92oNP0eXCJvEWQkjeAB0WK7Klca2IjEyJvMVns2pn12UaJPquX9DKg"
    #else
    private let state = String.randomString
    private let verifier = String.randomString
    #endif
    
    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    private var codeVerifier = String.randomString
    
    public var iksmSession: String? {
        get {
            keychain.getValue(forKey: .iksmSession)
        }
        set {
            if let newValue = newValue {
                keychain.setValue(value: newValue, forKey: .iksmSession)
            }
        }
    }
    
    public var sessionToken: String? {
        get {
            return keychain.getValue(forKey: .sessionToken)
        }
        set {
            if let newValue = newValue {
                keychain.setValue(value: newValue, forKey: .sessionToken)
            }
        }
    }
    
    public var playerId: String? {
        get {
            keychain.getValue(forKey: .playerId)
        }
        set {
            if let newValue = newValue {
                keychain.setValue(value: newValue, forKey: .playerId)
            }
        }
    }
    
    public var version: String {
        get {
            keychain.getValue(forKey: .version) ?? "1.11.0"
        }
        set {
            keychain.setValue(value: newValue, forKey: .version)
        }
    }
    
    public static let shared: SplatNet2 = SplatNet2()
    internal var task = Set<AnyCancellable>()
    
    public init() {}
    
    public init(iksmSession: String) {
        keychain.setValue(value: iksmSession, forKey: .iksmSession)
    }
    
    // テスト用
    init(sessionToken: String) {
        self.sessionToken = sessionToken
    }

    public func configure(iksmSession: String) {
        self.iksmSession = iksmSession
    }

    public func configure(sessionToken: String) {
        self.sessionToken = sessionToken
        getCookie()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            }, receiveValue: { response in
                print(response)
            })
            .store(in: &task)
    }
    
    public func configure(version: String) {
        self.version = version
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
    
    // Error Response
    // [400] Invalid Request
    @discardableResult
    public func getShiftSchedule() -> Future<[Response.ScheduleCoop], APIError> {
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
                        promise(.failure(APIError.decode))
                    }
                } else {
                    promise(.failure(APIError.decode))
                }
            } else {
                promise(.failure(APIError.failure))
            }
        }
    }

    // Error Response
    // [400] Invalid Request
    @discardableResult
    public func getSessionToken(sessionTokenCode: String) -> Future<Response.SessionToken, APIError> {
        let request = SessionToken(code: sessionTokenCode, verifier: verifier)
        return remote(request: request)
    }
    
    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    func getAccessToken() -> Future<Response.AccessToken, APIError> {
        let request = AccessToken()
        return remote(request: request)
    }
    
    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    func getSplatoonToken(accessToken: String) -> Future<Response.SplatoonToken, APIError> {
        Future { [self] promise in
            getParameterF(accessToken: accessToken, type: false)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { response in
                    // Flapg API
                    let request = SplatoonToken(from: response, version: version)
                    remote(request: request)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { _ in
                        }, receiveValue: { response in
                            promise(.success(response))
                        })
                        .store(in: &task)
                })
                .store(in: &task)
        }
    }
    
    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    func getSplatoonAccessToken(splatoonToken: String) -> Future<Response.SplatoonAccessToken, APIError> {
        Future { [self] promise in
            getParameterF(accessToken: splatoonToken, type: true)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { response in
                    // Flapg API
                    let request = SplatoonAccessToken(from: response, splatoonToken: splatoonToken, version: version)
                    remote(request: request)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { _ in
                        }, receiveValue: { response in
                            promise(.success(response))
                        })
                        .store(in: &task)
                })
                .store(in: &task)
        }
    }
    
    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    func getIksmSession(accessToken: String) -> Future<Response.IksmSession, APIError> {
        let request = IksmSession(accessToken: accessToken)
        return generate(request: request)
    }
    
    @discardableResult
    func getParameterF(accessToken: String, type: Bool) -> Future<Response.FlapgAPI, APIError> {
        let timestamp = Int(Date().timeIntervalSince1970)
        let request = S2SHash(accessToken: accessToken, timestamp: timestamp)
        
        return Future { [self] promise in
            remote(request: request)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    // S2SHash
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                        promise(.failure(APIError.s2shash))
                    }
                }, receiveValue: { (response: Response.S2SHash) in
                    // Flapg
                    print(response.hash)
                    let request = FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
                    remote(request: request)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                print(error)
                                promise(.failure(APIError.upgrade))
                            }
                        }, receiveValue: { (response: Response.FlapgAPI) in
                            promise(.success(response))
                        })
                        .store(in: &task)
                })
                .store(in: &task)
        }
    }
    
    @discardableResult
    public func convertResultWithJSONFormat(results: [Coop.Result]) -> [String] {
        return results.map{ String(data: try! encoder.encode($0), encoding: .utf8)! }
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
