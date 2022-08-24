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
import Metal

extension SplatNet2 {
    fileprivate func authorize<T: RequestType>(_ request: T, state: SignInState) -> AnyPublisher<T.ResponseType, SP2Error> {
        session
            .request(request, interceptor: self)
            .cURLDescription { request in
                DDLogInfo(request)
            }
            .validationWithSP2Error(decoder: decoder)
            .publishDecodable(type: T.ResponseType.self, decoder: decoder)
            .value()
            .retry(1)
            .handleEvents(receiveSubscription: { subscription in
                // どのリクエストが実行中か返す
                if request is SessionToken {
                    self.delegate?.willRunningSplatNet2SignIn()
                }
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
            .mapToSP2Error(delegate: self.delegate)
            .eraseToAnyPublisher()
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
    internal func getS2SHash(accessToken: String, timestamp: UInt64, state: SignInState) -> AnyPublisher<S2SHash.Response, SP2Error> {
        let request = S2SHash(accessToken: accessToken, timestamp: timestamp)
        return authorize(request, state: state)
    }

    /// FlapgTokenを取得
    internal func getFlapgToken(accessToken: String, timestamp: UInt64, response: S2SHash.Response, type: FlapgToken.FlapgType, state: SignInState)
    -> AnyPublisher<FlapgToken.Response, SP2Error> {
        let request = FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
        return authorize(request, state: state)
    }

    /// IminkTokenを取得
    internal func getIminkToken(token: AccessToken.Response, timestamp: UInt64, type: Imink.IminkType, state: SignInState)
    -> AnyPublisher<Imink.Response, SP2Error> {
        let request = Imink(accessToken: token.idToken, timestamp: timestamp, type: type)
        return authorize(request, state: state)
    }

    /// IminkTokenを取得
    internal func getIminkToken(token: SplatoonToken.Response, timestamp: UInt64, type: Imink.IminkType, state: SignInState)
    -> AnyPublisher<Imink.Response, SP2Error> {
        let request = Imink(accessToken: token.result.webApiServerCredential.accessToken, timestamp: timestamp, type: type)
        return authorize(request, state: state)
    }

    /// FlapgTokenを取得
    internal func getFlapgToken(response: S2SHash.Response, type: FlapgToken.FlapgType, state: SignInState)
    -> AnyPublisher<FlapgToken.Response, SP2Error> {
        let request = FlapgToken(response: response, type: type)
        return authorize(request, state: state)
    }

    /// SplatonTokenを取得
    internal func getSplatoonToken(token: AccessToken.Response, timestamp: UInt64, f: String)
    -> AnyPublisher<SplatoonToken.Response, SP2Error> {
        let request = SplatoonToken(accessToken: token.idToken, timestamp: timestamp, f: f, version: version)
        return authorize(request, state: .sessionToken(.app))
    }

    /// SplatoonAccessTokenを取得
    internal func getSplatoonAccessToken(token: SplatoonToken.Response, f: String, timestamp: UInt64)
    -> AnyPublisher<SplatoonAccessToken.Response, SP2Error> {
        let request = SplatoonAccessToken(accessToken: token.result.webApiServerCredential.accessToken, timestamp: timestamp, f: f, version: version)
        return authorize(request, state: .accessToken(.app))
    }

    /// IksmSessionを取得
    internal func getIksmSession(splatoonAccessToken: String)
    -> AnyPublisher<IksmSession.Response, SP2Error> {
        generate(accessToken: splatoonAccessToken, state: .iksmSession)
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
        var splatoonToken: SplatoonToken.Response!
        var accessToken: AccessToken.Response!
        let timestamp: UInt64 = UInt64(Date().timeIntervalSince1970) * 1000
        print(timestamp)

        return Future { promise in
            self.getAccessToken(sessionToken: sessionToken)
                .flatMap({ response -> AnyPublisher<Imink.Response, SP2Error> in
                    accessToken = response
                    return self.getIminkToken(token: response, timestamp: timestamp, type: Imink.IminkType.nso, state: .flapg(.nso))
                })
                .flatMap({
                    self.getSplatoonToken(token: accessToken, timestamp: timestamp, f: $0.f)
                })
                .flatMap({ response -> AnyPublisher<Imink.Response, SP2Error> in
                    splatoonToken = response
                    return self.getIminkToken(token: response, timestamp: timestamp, type: Imink.IminkType.app, state: .flapg(.app))
                })
                .flatMap({
                    self.getSplatoonAccessToken(token: splatoonToken, f: $0.f, timestamp: timestamp)
                })
                .flatMap({
                    self.getIksmSession(splatoonAccessToken: $0.result.accessToken)
                })
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            DDLogError(error)
                            promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(.success(UserInfo(sessionToken: sessionToken, response: response, user: splatoonToken)))
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
