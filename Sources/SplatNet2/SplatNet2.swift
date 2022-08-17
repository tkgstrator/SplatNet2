//
//  SplatNet2.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import CryptoKit
import Foundation
import KeychainAccess

open class SplatNet2: RequestInterceptor {
    /// アクセス用のセッション
    public let session: Session = {
        let configuration: URLSessionConfiguration = {
            let config = URLSessionConfiguration.default
            config.httpMaximumConnectionsPerHost = 1
            config.timeoutIntervalForRequest = 10
            return config
        }()
        let queue = DispatchQueue(label: "SplatNet2")
        return Session(configuration: configuration, rootQueue: queue, requestQueue: queue)
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

    /// X-Product Versionを自動でアップデートするかどうか
    internal let refreshable: Bool

    /// X-Product Versionを手動で設定する
    public func setXProductVersion(version: String) {
        #if DEBUG
        keychain.setVersion(version: version)
        #else
        DDLogWarn("This feature is only enabled for Debug build.")
        #endif
    }

    // JSONDecoder
    public let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// タスク管理
    public var task = Set<AnyCancellable>()
    /// Delegate
    public weak var delegate: SplatNet2SessionDelegate?

    /// 現在利用しているアカウント
    public var account: UserInfo {
        // バイト情報が更新されたらここが通知される
        // そのときにKeychainに最新のデータを入れる
        willSet {
            self.keychain.addAccount(newValue)
            self.accounts = self.keychain.getAccounts()
        }
    }

    /// 保存されている全てのアカウント
    public internal(set) var accounts: [UserInfo]

    public init(refreshable: Bool = false) {
        let accounts: [UserInfo] = keychain.getAccounts()
        self.accounts = accounts
        self.account = keychain.getAccount()
        self.refreshable = refreshable
    }

    public init(delegate: SplatNet2SessionDelegate, refreshable: Bool = false) {
        let accounts: [UserInfo] = keychain.getAccounts()
        self.accounts = accounts
        self.account = keychain.getAccount()
        self.delegate = delegate
        self.refreshable = refreshable
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

    /// リクエストを実行
    open func publish<T: RequestType>(_ request: T, isNeedOAuth: Bool = true) -> AnyPublisher<T.ResponseType, SP2Error> {
        // 認証不要なら常にNilを代入する
        let interceptor: AuthenticationInterceptor<SplatNet2>? = isNeedOAuth
        ? {
            switch request {
            case is XVersion:
                return nil
            default:
                break
            }
            if accounts.isEmpty {
                return nil
            }
            return AuthenticationInterceptor(authenticator: self, credential: account.credential)
        }()
        : nil

        return session
            .request(request, interceptor: interceptor)
            .cURLDescription { request in
                #if DEBUG
                DDLogInfo(request)
                #endif
            }
            .validationWithSP2Error(decoder: decoder)
            .publishDecodable(type: T.ResponseType.self, decoder: decoder)
            .value()
            .subscribe(on: DispatchQueue(label: "work.tkgstrator.splatnet2"), options: nil)
            .receive(on: RunLoop.main)
            .handleEvents(receiveSubscription: { subscription in
                self.delegate?.willReceiveSubscription(subscribe: subscription)
            }, receiveOutput: { output in
                self.delegate?.willReceiveOutput(output: output)
            }, receiveCompletion: { completion in
                self.delegate?.willReceiveCompletion(completion: completion)
            }, receiveCancel: {
                self.delegate?.willReceiveCancel()
            }, receiveRequest: { request in
                self.delegate?.willReceiveRequest(request: request)
            })
            .retry(1)
            .mapToSP2Error(delegate: self.delegate)
            .eraseToAnyPublisher()
    }

    /// X-Product Versionをセットする
    open func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest: URLRequest = urlRequest
        urlRequest.headers.update(name: "X-ProductVersion", value: version)
        completion(.success(urlRequest))
    }

    /// X-Product Versionが低いときに取得してアップデートする
    open func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let error = error.asSP2Error else {
            completion(.doNotRetry)
            return
        }
        switch error {
        case .responseValidationFailed(let failure):
            switch failure.failureReason {
            case .upgradeRequired:
                if refreshable {
                    getVersion()
                        .sink(receiveCompletion: { result in
                            switch result {
                            case .finished:
                                completion(.retry)
                            case .failure:
                                completion(.doNotRetry)
                            }
                        }, receiveValue: { response in
                            if let version = response.results.first?.version {
                                self.version = version
                            }
                        })
                        .store(in: &task)
                } else {
                    self.delegate?.failedWithUnavailableVersion(version: version)
                    completion(.doNotRetry)
                    return
                }
            default:
                completion(.doNotRetry)
                return
            }
        default:
            completion(.doNotRetry)
            return
        }
    }
}
