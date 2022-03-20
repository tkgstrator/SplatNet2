//
//  S2SHash.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation

internal class S2SHash: RequestType {
    typealias ResponseType = S2SHash.Response

    var method: HTTPMethod = .post
    var baseURL = URL(unsafeString: "https://elifessler.com/s2s/api/")
    var path: String = "gen2"
    var encoding: ParameterEncoding = URLEncoding.default
    var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]?

    init(accessToken: String, timestamp: Int) {
        self.parameters = [
            "naIdToken": accessToken,
            "timestamp": String(timestamp),
        ]
    }

    internal struct Response: Codable {
        let hash: String
    }
}
