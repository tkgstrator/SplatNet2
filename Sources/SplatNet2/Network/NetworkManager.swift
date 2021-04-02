import Foundation
import Alamofire
import Combine
import CryptoKit

public final class NetworkManager {
    let sessionToken: String? = nil
    let iksmSession: String? = nil

    #if DEBUG
    private let state = "v1MguHzdCzhY7W7DMciwfFGPbzV0qdukFOnPX6czsT7m2END726qGJRrScHUT5AmZ2oS7RArsVj2z4eDH4BqThJpvQv7rgLIrHSOzp4NtwS3kFG3kIOqSE4vHCDUYE0X"
    private let verifier = "VVSJwmWlQonJu047zDA2jgUtyuK3taxUV8tmUyQnpxLk4Q1ZBAUNvb6d1QPbyOKVbhKtr2IowR92oNP0eXCJvEWQkjeAB0WK7Klca2IjEyJvMVns2pn12UaJPquX9DKg"
    #else
    private let state = String.randomString
    private let verifier = String.randomString
    #endif

    private var codeVerifier = String.randomString
    public static let shared = NetworkManager()
    private init() {}

    public func configure() {

    }

    var oauthURL: URL {
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

    //    @discardableresult
    //    public func getsessiontoken(sessiontokencode: string, completion: @escaping (string?, apierror?) -> void) {
    //        let request = apirequest.sessiontoken(code: sessiontokencode, verifier: verifier)
    //        let _ = networkpublisher.publish(request)
    //            .receive(on: DispatchQueue.main)
    //            .sink(receiveCompletion: { completion in
    //                switch completion {
    //                case .finished:
    //                    break
    //                case .failure(let error):
    //                    break
    ////                    completion(nil, error)
    //                }
    //            }, receiveValue: { (response: APIResponse.SessionToken) in
    //                completion(response.sessionToken, nil)
    //            })
    //    }

    // Error Response
    // [400] Invalid Request
    @discardableResult
    public func getSessionToken(sessionTokenCode: String) -> Future<APIResponse.SessionToken, APIError> {
        let request = APIRequest.SessionToken(code: sessionTokenCode, verifier: verifier)
        return remote(request: request)
    }

    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    public func getAccessToken(sessionToken: String) -> Future<APIResponse.AccessToken, APIError> {
        let request = APIRequest.AccessToken(sessionToken: sessionToken)
        return remote(request: request)
    }

    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    public func getSplatoonToken(accessToken: String, version: String = "1.10.1") -> Future<APIResponse.SplatoonToken, APIError> {
        var task: [AnyCancellable] = []
        return Future { [self] promise in
            task.append(getParameterF(accessToken: accessToken, type: false)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { response in
                    // Flapg API
                    let request = APIRequest.SplatoonToken(from: response, version: version)
                    task.append(NetworkPublisher.publish(request)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { _ in
                        }, receiveValue: { response in
                            promise(.success(response))
                        }))
                }))
        }
    }

    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    public func getSplatoonAccessToken(splatoonToken: String, version: String = "1.10.1") -> Future<APIResponse.SplatoonAccessToken, APIError> {
        var task: [AnyCancellable] = []
        return Future { [self] promise in
            task.append(getParameterF(accessToken: splatoonToken, type: true)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }, receiveValue: { response in
                    // Flapg API
                    let request = APIRequest.SplatoonAccessToken(from: response, splatoonToken: splatoonToken, version: version)
                    task.append(NetworkPublisher.publish(request)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { _ in
                        }, receiveValue: { response in
                            promise(.success(response))
                        }))
                }))
        }
    }

    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    public func getIksmSession(accessToken: String) -> Future<APIResponse.IksmSession, APIError> {
        let request = APIRequest.IksmSession(accessToken: accessToken)
        return generate(request: request)
    }

    @discardableResult
    private func getParameterF(accessToken: String, version: String = "1.10.1", type: Bool) -> Future<APIResponse.FlapgAPI, APIError> {
        var task: [AnyCancellable] = []
        let timestamp = Int(Date().timeIntervalSince1970)
        let request = APIRequest.S2SHash(accessToken: accessToken, timestamp: timestamp)

        return Future { promise in
            task.append(NetworkPublisher.publish(request)
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
                    task.append(NetworkPublisher.publish(request)
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
                        }))
                }))
        }
    }

    private func generate<Request: APIRequest.IksmSession>(request: Request) -> Future<APIResponse.IksmSession, APIError> {
        NetworkPublisher.generate(request)
    }

    private func remote<Request: RequestProtocol>(request: Request) -> Future<Request.ResponseType, APIError> {
        NetworkPublisher.publish(request)
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
