//
//  Session.swift
//  SplatNet2
//
//  Created by devonly on 2021/06/27.
//

import Foundation
import Combine

extension SplatNet2 {
    // セッショントークンコードからセッショントークンを取得
    @discardableResult
    func getSessionToken(sessionTokenCode: String, verifier: String) -> Future<SessionToken.Response, APIError> {
        let request = SessionToken(code: sessionTokenCode, verifier: verifier)
        return remote(request: request)
    }
    
    // セッショントークンからアクセストークンを取得
    @discardableResult
    func getAccessToken(sessionToken: String) -> Future<AccessToken.Response, APIError> {
        let request = AccessToken(sessionToken: sessionToken)
        return remote(request: request)
    }
    
    // アクセストークンからスプラトゥーントークンを取得
    @discardableResult
    func getSplatoonToken(parameter: FlapgToken.Response) -> Future<SplatoonToken.Response, APIError> {
        let request = SplatoonToken(from: parameter, version: version)
        return remote(request: request)
    }
    
    // Splatoon Access Token
    @discardableResult
    func getSplatoonAccessToken(splatoonToken: String, parameter: FlapgToken.Response) -> Future<SplatoonAccessToken.Response, APIError> {
        let request = SplatoonAccessToken(from: parameter, splatoonToken: splatoonToken, version: version)
        return remote(request: request)
    }

    func getS2SHash(accessToken: String, timestamp: Int) -> Future<S2SHash.Response, APIError> {
        let request = S2SHash(accessToken: accessToken, timestamp: timestamp, userAgent: userAgent)
        return remote(request: request)
    }
    
    // Parameter F
    @discardableResult
    func getParameterF(accessToken: String, hash response: S2SHash.Response, timestamp: Int, type: FlapgToken.FlapgType) -> Future<FlapgToken.Response, APIError> {
        let request = FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
        return remote(request: request)
    }
    
    // Iksm Session
    @discardableResult
    func getIksmSession(from response: SplatoonAccessToken.Response) -> Future<IksmSession.Response, APIError> {
        let request = IksmSession(accessToken: response.result.accessToken)
        return generate(request: request)
    }
}
