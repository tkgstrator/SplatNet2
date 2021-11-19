//
//  SplatoonToken.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

internal class SplatoonToken: RequestType {
    typealias ResponseType = SplatoonToken.Response

    var method: HTTPMethod = .post
    var baseURL = URL(unsafeString: "https://api-lp1.znc.srv.nintendo.net/")
    var path: String = "v1/Account/Login"
    var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]?

    init(from result: FlapgToken.Response, version: String) {
        self.headers = [
            "X-ProductVersion": "\(version)",
            "X-Platform": "Android",
        ]
        self.parameters = [
            "parameter": [
                "f": result.result.f,
                "naIdToken": result.result.p1,
                "timestamp": result.result.p2,
                "requestId": result.result.p3,
                "naCountry": "JP",
                "naBirthday": "1990-01-01",
                "language": "ja-JP",
            ],
        ]
    }

    internal struct Response: Codable {
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
