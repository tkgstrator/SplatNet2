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
import SwiftyJSON

open class SplatNet2: ObservableObject, RequestInterceptor {
    /// アクセス用のセッション
    internal let session: Session
    // JSON Encoder
    internal var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .sortedKeys
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
    @Published public var account: UserInfo {
        willSet {
            // アカウントを上書きするとその値をKeychainに書き込む
            try? keychain.setValue(newValue)
            // IksmSessionの値を上書きする
            self.iksmSession = newValue.iksmSession
            self.sessionToken = newValue.sessionToken

            // アカウント一覧を更新する
            guard let userdata = try? keychain.getValue() else {
                return
            }
            self.accounts = userdata.accounts
        }
    }

    /// 保存されている全てのアカウント
    @Published public internal(set) var accounts: [UserInfo] {
        willSet {
            try? keychain.setValue(newValue)
        }
    }

    /// ユーザーエージェント
    internal let userAgent: String

    /// X-Product Version
    @Published public internal(set) var version: String {
        willSet {
            try? keychain.setVersion(newValue)
        }
    }

    /// Iksm Session
    @Published public private(set) var iksmSession: String?

    /// Session Token
    @Published public private(set) var sessionToken: String?

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
            self.version = version
            self.userAgent = "SplatNet2/@tkgling"
            // 保存されているアカウントから最も新しいものを選択
            if let account = userdata.accounts.first {
                self.account = account
            } else {
                // 存在しない場合は仮のデータで埋める
                self.account = UserInfo(nsaid: "0000000000000000", nickname: "Unregistered")
            }
            self.accounts = keychain.getAccounts()
            self.iksmSession = account.iksmSession
            self.sessionToken = account.sessionToken
        } catch {
            // アカウント情報が得られないとき
            self.version = version
            self.userAgent = "SplatNet2/@tkgling"
            self.account = UserInfo(nsaid: "0000000000000000", nickname: "Unregistered")
            self.accounts = keychain.getAccounts()
            self.iksmSession = account.iksmSession
            self.sessionToken = account.sessionToken
        }
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

    internal func update(coop response: Results.Response) {
        account.coop = CoopInfo(from: response)
        try? keychain.setValue(account)
    }

    public func addDummyAccount() {
        self.accounts.append(UserInfo(nsaid: "0000000000000000", nickname: "DUMMY"))
    }

    public func expiredIksmSession() {
        self.iksmSession = String(String.randomString.prefix(32))
    }

    open func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        print(urlRequest.url?.absoluteString)
        var urlRequest = urlRequest
        urlRequest.headers.add(.userAgent("Salmonia3/tkgling"))
        /// APIにアクセスするときはiksmSessionを設定する
        if let url = urlRequest.url?.absoluteString, url.contains("app.splatoon2.nintendo.net") {
            guard let iksmSession = iksmSession else {
                completion(.failure(AFError.sessionInvalidated(error: nil)))
                return
            }
            urlRequest.headers.add(HTTPHeader(name: "cookie", value: "iksm_session=\(iksmSession)"))
        }
        completion(.success(urlRequest))
    }

    open func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print(request.cURLDescription(), error.asAFError)
        // リトライ回数は一回のみ
        if request.retryCount >= 1 {
            completion(.doNotRetryWithError(error))
            return
        }

        // セッショントークンが切れているのは403だけ
        if let statusCode = request.response?.statusCode, statusCode == 403, let sessionToken = sessionToken {
            getCookie(sessionToken: sessionToken)
                .sink(receiveCompletion: { result in
                    switch result {
                    case .finished:
                        break
                    case .failure(let error):
                        completion(.doNotRetryWithError(error))
                    }
                }, receiveValue: { response in
                    // アカウント情報を更新
                    self.account = response
                    completion(.retry)
                })
                .store(in: &task)
        } else {
            completion(.doNotRetry)
            return
        }
    }
}

extension SplatNet2: DataPreprocessor {
    public func preprocess(_ data: Data) throws -> Data {
        // APPエラーを返す
        if let failure = try? decoder.decode(SP2Error.Failure.APP.self, from: data) {
            throw SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: .upgradeRequired), failure: failure)
        }
        return data
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
