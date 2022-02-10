//
//  SplatNet2+Cookie.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/04.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation
import KeychainAccess

extension SplatNet2: RequestInterceptor {
    fileprivate func authorize<T: RequestType>(_ request: T, state: SignInState) -> AnyPublisher<T.ResponseType, SP2Error> {
        session
            .request(request, interceptor: self)
            .cURLDescription { request in
                DDLogInfo(request)
            }
            .validationWithSP2Error(decoder: decoder)
            .publishDecodable(type: T.ResponseType.self, decoder: decoder)
            .value()
            .handleEvents(receiveSubscription: { subscription in
                // どのリクエストが実行中か返す
                self.delegate?.progressSignIn(state: state)
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
            .mapError({ error -> SP2Error in
                DDLogError(error)
                guard let sp2Error = error.asSP2Error else {
                    return SP2Error.requestAdaptionFailed
                }
                return sp2Error
            })
            .eraseToAnyPublisher()
    }

    #warning("エラー処理がガバい")
    /// X-Product Versionをセットする
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        var urlRequest: URLRequest = urlRequest
        urlRequest.headers.update(name: "X-ProductVersion", value: version)
        completion(.success(urlRequest))
    }

    #warning("未実装")
    /// X-Product Versionが低いときに取得してアップデートする
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let error = error.asSP2Error else {
            completion(.doNotRetry)
            return
        }

        DDLogError("RequestInterceptor: Retry \(error)")

        switch error {
        case .responseValidationFailed(let failure):
            switch failure.reason {
            case .upgradeRequired:
                self.delegate?.failedWithUnavailableVersion(version: version)
                completion(.doNotRetryWithError(error))
                return
            default:
                completion(.doNotRetryWithError(error))
                return
            }
        default:
            completion(.doNotRetryWithError(error))
            return
        }
    }

    /// SessionTokenを取得
    internal func getSessionToken(sessionTokenCode: String, verifier: String)
    -> AnyPublisher<SessionToken.Response, SP2Error> {
        let request = SessionToken(code: sessionTokenCode, verifier: verifier)
        return authorize(request, state: .sessionToken(.nso))
    }

    /// AccessTokenを取得
    internal func getAccessToken(sessionToken: String)
    -> AnyPublisher<AccessToken.Response, SP2Error> {
        let request = AccessToken(sessionToken: sessionToken)
        return authorize(request, state: .accessToken(.nso))
    }

    /// S2sHashを取得
    internal func getS2SHash(accessToken: String, timestamp: Int) -> AnyPublisher<S2SHash.Response, SP2Error> {
        let request = S2SHash(accessToken: accessToken, timestamp: timestamp)
        return authorize(request, state: .s2sHash(.nso))
    }

    /// FlapgTokenを取得
    internal func getFlapgToken(accessToken: String, timestamp: Int, response: S2SHash.Response, type: FlapgToken.FlapgType)
    -> AnyPublisher<FlapgToken.Response, SP2Error> {
        let request = FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
        return authorize(request, state: .flapg(.nso))
    }

    /// SplatonTokenを取得
    internal func getSplatoonToken(response: FlapgToken.Response)
    -> AnyPublisher<SplatoonToken.Response, SP2Error> {
        let request = SplatoonToken(from: response, version: version)
        return authorize(request, state: .sessionToken(.app))
    }

    /// SplatoonAccessTokenを取得
    internal func getSplatoonAccessToken(splatoonToken: String, response: FlapgToken.Response)
    -> AnyPublisher<SplatoonAccessToken.Response, SP2Error> {
        let request = SplatoonAccessToken(from: response, splatoonToken: splatoonToken, version: version)
        return authorize(request, state: .sessionToken(.app))
    }

    /// IksmSessionを取得
    internal func getIksmSession(splatoonAccessToken: String)
    -> AnyPublisher<IksmSession.Response, SP2Error> {
        generate(accessToken: splatoonAccessToken)
    }

    /// バージョンをAppStoreから取得
    public func getVersion()
    -> AnyPublisher<XVersion.Response, SP2Error> {
        let request = XVersion()
        return publish(request)
    }

    #warning("クソコード要修正")
    /// SessionTokenからIksmSessionを取得
    // swiftlint:disable function_body_length
    public func getCookie(sessionToken: String)
    -> AnyPublisher<UserInfo, SP2Error> {
        var splatoonToken: String = ""
        var accessToken: String = ""
        var thumbnailURL: String = ""
        var nickname: String = ""
        var membership = false
        let timestamp = Int(Date().timeIntervalSince1970)

        return Future { promise in
            self.getAccessToken(sessionToken: sessionToken)
                .flatMap({ response -> AnyPublisher<S2SHash.Response, SP2Error> in
                    accessToken = response.accessToken
                    return self.getS2SHash(accessToken: response.accessToken, timestamp: timestamp)
                })
                .flatMap({
                    self.getFlapgToken(accessToken: accessToken, timestamp: timestamp, response: $0, type: .nso)
                })
                .flatMap({
                    self.getSplatoonToken(response: $0)
                })
                .flatMap({ response -> AnyPublisher<S2SHash.Response, SP2Error> in
                    splatoonToken = response.result.webApiServerCredential.accessToken
                    nickname = response.result.user.name
                    thumbnailURL = response.result.user.imageUri
                    membership = response.result.user.membership.active
                    return self.getS2SHash(accessToken: splatoonToken, timestamp: timestamp)
                })
                .flatMap({
                    self.getFlapgToken(accessToken: splatoonToken, timestamp: timestamp, response: $0, type: .app)
                })
                .flatMap({
                    self.getSplatoonAccessToken(splatoonToken: splatoonToken, response: $0)
                })
                .flatMap({
                    self.getIksmSession(splatoonAccessToken: $0.result.accessToken)
                })
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(
                        .success(
                            UserInfo(
                                sessionToken: sessionToken,
                                response: response,
                                nickname: nickname,
                                membership: membership,
                                thumbnailURL: thumbnailURL
                            )
                        )
                    )
                })
                .store(in: &self.task)
        }
        .eraseToAnyPublisher()
    }
    // swiftlint:enable function_body_length

    /// IksmSessionをsessionTokenCodeから取得
    internal func getCookie(code sessionTokenCode: String, verifier: String)
    -> AnyPublisher<UserInfo, SP2Error> {
        getSessionToken(sessionTokenCode: sessionTokenCode, verifier: verifier)
            .flatMap({
                self.getCookie(sessionToken: $0.sessionToken)
            })
            .eraseToAnyPublisher()
    }
}
