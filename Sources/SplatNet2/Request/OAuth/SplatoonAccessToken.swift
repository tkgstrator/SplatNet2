//
//  SplatoonAccessToken.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation

internal class SplatoonAccessToken: RequestType {
    typealias ResponseType = SplatoonAccessToken.Response

    var method: HTTPMethod = .post
    var baseURL = URL(unsafeString: "https://api-lp1.znc.srv.nintendo.net/")
    var path: String = "v2/Game/GetWebServiceToken"
    var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]?

    init(accessToken: String, timestamp: UInt64, f: String, version: String) {
        self.headers = [
            "X-Platform": "Android",
            "Authorization": "Bearer \(accessToken)",
        ]
        self.parameters = [
            "parameter": [
                "f": f,
                "id": 5_741_031_244_955_648,
                "registrationToken": accessToken,
                "timestamp": timestamp,
                "requestId": "00000000-0000-0000-0000-000000000000",
            ],
        ]
    }

    internal struct Response: Codable {
        var correlationId: String
        var result: AccessToken
        var status: Int

        struct AccessToken: Codable {
            var accessToken: String
            var expiresIn: Int
        }
    }
}
