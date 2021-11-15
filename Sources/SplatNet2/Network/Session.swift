//
//  Session.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/06/27.
//

import Foundation
import Combine

extension SplatNet2 {
    // セッショントークンコードからセッショントークンを取得
    @discardableResult
    func getSessionToken(sessionTokenCode: String, verifier: String) -> AnyPublisher<SessionToken.Response, APIError> {
        NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.sessiontoken)
        let request = SessionToken(code: sessionTokenCode, verifier: verifier)
        return remote(request: request).eraseToAnyPublisher()
    }
    
    // セッショントークンからアクセストークンを取得
    @discardableResult
    func getAccessToken(sessionToken: String) -> AnyPublisher<AccessToken.Response, APIError> {
        NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.accesstoken)
        let request = AccessToken(sessionToken: sessionToken)
        return remote(request: request).eraseToAnyPublisher()
    }
    
    // アクセストークンからスプラトゥーントークンを取得
    @discardableResult
    func getSplatoonToken(parameter: FlapgToken.Response) -> AnyPublisher<SplatoonToken.Response, APIError> {
        NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.splatoontoken)
        let request = SplatoonToken(from: parameter, version: version)
        return remote(request: request).eraseToAnyPublisher()
    }
    
    // Splatoon Access Token
    @discardableResult
    func getSplatoonAccessToken(splatoonToken: String, parameter: FlapgToken.Response) -> AnyPublisher<SplatoonAccessToken.Response, APIError> {
        NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.splatoonaccesstoken)
        let request = SplatoonAccessToken(from: parameter, splatoonToken: splatoonToken, version: version)
        return remote(request: request).eraseToAnyPublisher()
    }

    func getS2SHash(accessToken: String, timestamp: Int, type: FlapgToken.FlapgType) -> AnyPublisher<S2SHash.Response, APIError> {
        switch type {
        case .app:
            NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.s2shashapp)
        case .nso:
            NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.s2shashnso)
        }
        let request = S2SHash(accessToken: accessToken, timestamp: timestamp, userAgent: userAgent)
        return remote(request: request).eraseToAnyPublisher()
//        return getIkaHash(accessToken: accessToken, timestamp: timestamp)
    }
    
    open func getIkaHash(accessToken: String, timestamp: Int) -> AnyPublisher<S2SHash.Response, APIError> {
        Future { promise in
            promise(.success(S2SHash.Response(hash: "")))
        }.eraseToAnyPublisher()
    }
    
    // Parameter F
    @discardableResult
    func getParameterF(accessToken: String, hash response: S2SHash.Response, timestamp: Int, type: FlapgToken.FlapgType) -> AnyPublisher<FlapgToken.Response, APIError> {
        switch type {
        case .app:
            NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.flapgapp)
        case .nso:
            NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.flapgnso)
        }
        let request = FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
        return remote(request: request).eraseToAnyPublisher()
    }
    
    // Iksm Session
    @discardableResult
    func getIksmSession(from response: SplatoonAccessToken.Response) -> AnyPublisher<IksmSession.Response, APIError> {
        NotificationCenter.default.post(name: SplatNet2.signIn, object: SignInState.iksmsession)
        let request = IksmSession(accessToken: response.result.accessToken)
        return generate(request: request).eraseToAnyPublisher()
    }
}
