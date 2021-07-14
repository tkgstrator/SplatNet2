//
//  AccessToken.swift
//  SplatNet2
//
//  Created by devonly on 2021/07/13.
//

import Foundation
import Alamofire

public class AccessToken: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://accounts.nintendo.com/")!
    public var path: String = "connect/1.0.0/api/token"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = AccessToken.Response
    
    init(sessionToken: String?) {
        if let sessionToken = sessionToken {
            self.parameters = [
                "client_id": "71b963c1b7b6d119",
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer-session-token",
                "session_token": sessionToken
            ]
        }
    }
    
    public struct Response: Codable {
        var accessToken: String
        var expiresIn: Int
        var idToken: String
        var scope: [String]
        var tokenType: String
    }

}
