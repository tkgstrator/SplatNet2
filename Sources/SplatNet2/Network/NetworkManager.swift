import Foundation
import Alamofire
import Combine
import CryptoKit

public final class SplatNet2 {
    
    #if DEBUG
    private let state = "v1MguHzdCzhY7W7DMciwfFGPbzV0qdukFOnPX6czsT7m2END726qGJRrScHUT5AmZ2oS7RArsVj2z4eDH4BqThJpvQv7rgLIrHSOzp4NtwS3kFG3kIOqSE4vHCDUYE0X"
    private let verifier = "VVSJwmWlQonJu047zDA2jgUtyuK3taxUV8tmUyQnpxLk4Q1ZBAUNvb6d1QPbyOKVbhKtr2IowR92oNP0eXCJvEWQkjeAB0WK7Klca2IjEyJvMVns2pn12UaJPquX9DKg"
    #else
    private let state = String.randomString
    private let verifier = String.randomString
    #endif
    
    private var codeVerifier = String.randomString
    var iksmSession: String
    var sessionToken: String
    var version: String
    var task = Set<AnyCancellable>()
    
    public convenience init(iksmSession: String = "", sessionToken: String = "", version: String = "1.10.1") {
        self.init()
        self.iksmSession = iksmSession
        self.sessionToken = sessionToken
        self.version = version
    }
    
    public init() {
        self.iksmSession = ""
        self.sessionToken = ""
        self.version = "1.10.1"
    }
    
    public func configure(iksmSession: String, sessionToken: String) {
        self.iksmSession = iksmSession
        self.sessionToken = sessionToken
    }
    
    public var oauthURL: URL {
        print(verifier, verifier.codeChallenge, state)
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
    func getSessionToken(sessionTokenCode: String) -> Future<APIResponse.SessionToken, APIError> {
        let request = APIRequest.SessionToken(code: sessionTokenCode, verifier: verifier)
        return remote(request: request)
    }
    
    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    func getAccessToken() -> Future<APIResponse.AccessToken, APIError> {
        let request = APIRequest.AccessToken(sessionToken: sessionToken)
        return remote(request: request)
    }
    
    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    func getSplatoonToken(accessToken: String) -> Future<APIResponse.SplatoonToken, APIError> {
        Future { [self] promise in
            getParameterF(accessToken: accessToken, type: false)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { response in
                    // Flapg API
                    let request = APIRequest.SplatoonToken(from: response, version: version)
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
    func getSplatoonAccessToken(splatoonToken: String) -> Future<APIResponse.SplatoonAccessToken, APIError> {
        Future { [self] promise in
            getParameterF(accessToken: splatoonToken, type: true)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { response in
                    // Flapg API
                    let request = APIRequest.SplatoonAccessToken(from: response, splatoonToken: splatoonToken, version: version)
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
    func getIksmSession(accessToken: String) -> Future<APIResponse.IksmSession, APIError> {
        let request = APIRequest.IksmSession(accessToken: accessToken)
        return generate(request: request)
    }
    
    @discardableResult
    func getParameterF(accessToken: String, type: Bool) -> Future<APIResponse.FlapgAPI, APIError> {
        let timestamp = Int(Date().timeIntervalSince1970)
        let request = APIRequest.S2SHash(accessToken: accessToken, timestamp: timestamp)
        
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
                }, receiveValue: { (response: APIResponse.S2SHash) in
                    // Flapg
                    print(response.hash)
                    let request = APIRequest.FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
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
                        }, receiveValue: { (response: APIResponse.FlapgAPI) in
                            promise(.success(response))
                        })
                        .store(in: &task)
                })
                .store(in: &task)
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
