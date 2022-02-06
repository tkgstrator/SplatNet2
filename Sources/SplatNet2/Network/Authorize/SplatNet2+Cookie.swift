//
//  SplatNet2+Cookie.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/04.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Combine
import Foundation
import KeychainAccess

extension SplatNet2 {
    /// SessionTokenを取得
    internal func getSessionToken(sessionTokenCode: String, verifier: String)
    -> AnyPublisher<SessionToken.Response, SP2Error> {
        let request = SessionToken(code: sessionTokenCode, verifier: verifier)
        return publish(request)
    }

    /// AccessTokenを取得
    internal func getAccessToken(sessionToken: String)
    -> AnyPublisher<AccessToken.Response, SP2Error> {
        let request = AccessToken(sessionToken: sessionToken)
        return publish(request)
    }

    /// S2sHashを取得
    internal func getS2SHash(accessToken: String, timestamp: Int) -> AnyPublisher<S2SHash.Response, SP2Error> {
        let request = S2SHash(accessToken: accessToken, timestamp: timestamp)
        return publish(request)
    }

    /// FlapgTokenを取得
    internal func getFlapgToken(accessToken: String, timestamp: Int, response: S2SHash.Response, type: FlapgToken.FlapgType)
    -> AnyPublisher<FlapgToken.Response, SP2Error> {
        let request = FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
        return publish(request)
    }

    /// SplatonTokenを取得
    internal func getSplatoonToken(response: FlapgToken.Response)
    -> AnyPublisher<SplatoonToken.Response, SP2Error> {
        let request = SplatoonToken(from: response, version: version)
        return publish(request)
    }

    /// SplatoonAccessTokenを取得
    internal func getSplatoonAccessToken(splatoonToken: String, response: FlapgToken.Response)
    -> AnyPublisher<SplatoonAccessToken.Response, SP2Error> {
        let request = SplatoonAccessToken(from: response, splatoonToken: splatoonToken, version: version)
        return publish(request)
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
