//  swiftlint:disable:this file_name
//
//  Cookie.swift
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
    internal func getSessionToken(sessionTokenCode: String, verifier: String)
    -> AnyPublisher<SessionToken.Response, AFError> {
        let request = SessionToken(code: sessionTokenCode, verifier: verifier)
        return publish(request)
    }

    internal func getAccessToken(sessionToken: String)
    -> AnyPublisher<AccessToken.Response, AFError> {
        let request = AccessToken(sessionToken: sessionToken)
        return publish(request)
    }

//    internal func getS2SHash(accessToken: String) -> AnyPublisher<S2SHash.Response, SP2Error> {
//        let timestamp = Int(Date().timeIntervalSince1970)
//        let request = S2SHash(accessToken: accessToken, timestamp: timestamp, userAgent: userAgent)
//        return publish(request)
//    }

    internal func getS2SHash(accessToken: String)
    -> AnyPublisher<S2SHash.Response, AFError> {
        let timestamp = Int(Date().timeIntervalSince1970)
        return Future { promise in
            promise(.success(S2SHash.Response(accessToken: accessToken, timestamp: timestamp)))
        }
        .eraseToAnyPublisher()
    }

    internal func getFlapgToken(response: S2SHash.Response, type: FlapgToken.FlapgType)
    -> AnyPublisher<FlapgToken.Response, AFError> {
        let request = FlapgToken(accessToken: response.accessToken, timestamp: response.timestamp, hash: response.hash, type: type)
        return publish(request)
    }

    internal func getSplatoonToken(response: FlapgToken.Response)
    -> AnyPublisher<SplatoonToken.Response, AFError> {
        let request = SplatoonToken(from: response, version: version)
        return publish(request)
    }

    internal func getSplatoonAccessToken(splatoonToken: String, response: FlapgToken.Response)
    -> AnyPublisher<SplatoonAccessToken.Response, AFError> {
        let request = SplatoonAccessToken(from: response, splatoonToken: splatoonToken, version: version)
        return publish(request)
    }

    internal func getIksmSession(splatoonAccessToken: String)
    -> AnyPublisher<IksmSession.Response, AFError> {
        generate(accessToken: splatoonAccessToken)
    }

    public func getCookie(sessionToken: String)
    -> AnyPublisher<UserInfo, SP2Error> {
        var splatoonToken: String = ""
        var thumbnailURL: String = ""
        var nickname: String = ""
        var membership = false

        return Future { promise in
            self.getAccessToken(sessionToken: sessionToken)
                .flatMap({
                    self.getS2SHash(accessToken: $0.accessToken)
                })
                .flatMap({
                    self.getFlapgToken(response: $0, type: .nso)
                })
                .flatMap({
                    self.getSplatoonToken(response: $0)
                })
                .flatMap({ response -> AnyPublisher<S2SHash.Response, AFError> in
                    splatoonToken = response.result.webApiServerCredential.accessToken
                    nickname = response.result.user.name
                    thumbnailURL = response.result.user.imageUri
                    membership = response.result.user.membership.active
                    return self.getS2SHash(accessToken: splatoonToken)
                })
                .flatMap({
                    self.getFlapgToken(response: $0, type: .app)
                })
                .flatMap({
                    self.getSplatoonAccessToken(splatoonToken: splatoonToken, response: $0)
                })
                .flatMap({
                    self.getIksmSession(splatoonAccessToken: $0.result.accessToken)
                })
                .mapError({ _ in
                    SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: .notFound), failure: nil)
                })
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished")
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(
                        .success(
                            UserInfo(sessionToken: sessionToken, response: response, nickname: nickname, membership: membership, imageUri: thumbnailURL)
                        )
                    )
                })
                .store(in: &self.task)
        }
        .eraseToAnyPublisher()
    }

    internal func getCookie(code sessionTokenCode: String, verifier: String)
    -> AnyPublisher<UserInfo, SP2Error> {
        Future { promise in
            self.getSessionToken(sessionTokenCode: sessionTokenCode, verifier: verifier)
                .mapError({ _ in
                    SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: .notFound), failure: nil)
                })
                .flatMap({
                    self.getCookie(sessionToken: $0.sessionToken)
                })
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
                .store(in: &self.task)
        }
        .eraseToAnyPublisher()
    }
}
