//
//  SplatoonToken.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//

import Foundation
import Alamofire

public class SplatoonToken: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://api-lp1.znc.srv.nintendo.net/")!
    public var path: String = "v1/Account/Login"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = SplatoonToken.Response
    
    init(from result: FlapgToken.Response, version: String) {
        self.headers = [
            "X-ProductVersion": "\(version)",
            "X-Platform": "Android"
        ]
        self.parameters = [
            "parameter": [
                "f": result.result.f,
                "naIdToken": result.result.p1,
                "timestamp": result.result.p2,
                "requestId": result.result.p3,
                "naCountry": "JP",
                "naBirthday": "1990-01-01",
                "language": "ja-JP"
            ]
        ]
    }
    
    public struct Response: Codable {
        var result: SplatoonTokenResult
        var status: Int
        var correlationId: String

        struct SplatoonTokenResult: Codable {
            var webApiServerCredential: WebAPIServerCredential
            var user: WebAPIServerUser
            var firebaseCredential: FirebaseCredential
        }

        struct WebAPIServerUser: Codable {
            var name: String
            var imageUri: String
            var id: Int
            var supportId: String
            var membership: Membership
        }

        struct Membership: Codable {
            var active: Bool
        }

        struct FirebaseCredential: Codable {
            var expiresIn: Int
            var accessToken: String
        }

        struct WebAPIServerCredential: Codable {
            var expiresIn: Int
            var accessToken: String
        }
    }
}
