//
//  Session.swift
//  
//
//  Created by devonly on 2021/06/27.
//

import Foundation
import Combine

extension SplatNet2 {
    // セッショントークンコードからセッショントークンを取得
    @discardableResult
    public func getSessionToken(sessionTokenCode: String) -> Future<Response.SessionToken, APIError> {
        let request = SessionToken(code: sessionTokenCode, verifier: verifier)
        return remote(request: request)
    }
    
    // セッショントークンからアクセストークンを取得
    @discardableResult
    func getAccessToken(sessionToken: String) -> Future<Response.AccessToken, APIError> {
        let request = AccessToken(sessionToken: sessionToken)
        return remote(request: request)
    }
    
    // アクセストークンからスプラトゥーントークンを取得
    @discardableResult
    func getSplatoonToken(parameter: Response.FlapgAPI) -> Future<Response.SplatoonToken, APIError> {
        let request = SplatoonToken(from: parameter, version: version)
        return remote(request: request)
    }
    
    // Splatoon Access Token
    @discardableResult
    func getSplatoonAccessToken(splatoonToken: String, parameter: Response.FlapgAPI) -> Future<Response.SplatoonAccessToken, APIError> {
        let request = SplatoonAccessToken(from: parameter, splatoonToken: splatoonToken, version: version)
        return remote(request: request)
    }

    func getS2SHash(accessToken: String, timestamp: Int) -> Future<Response.S2SHash, APIError> {
        let request = S2SHash(accessToken: accessToken, timestamp: timestamp)
        return remote(request: request)
    }
    
    // Parameter F
    @discardableResult
    func getParameterF(accessToken: String, hash response: Response.S2SHash, timestamp: Int, type: FlapgToken.FlapgType) -> Future<Response.FlapgAPI, APIError> {
        let request = FlapgToken(accessToken: accessToken, timestamp: timestamp, hash: response.hash, type: type)
        return remote(request: request)
    }
    
    // Iksm Session
    @discardableResult
    func getIksmSession(from response: Response.SplatoonAccessToken) -> Future<Response.IksmSession, APIError> {
        let request = IksmSession(accessToken: response.result.accessToken)
        return generate(request: request)
    }
}
