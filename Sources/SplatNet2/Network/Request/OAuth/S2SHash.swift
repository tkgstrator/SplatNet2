//
//  S2SHash.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//
//  swiftlint:disable discouraged_optional_collection

import Alamofire
import Foundation

internal class S2SHash: RequestType {
    typealias ResponseType = S2SHash.Response

    var method: HTTPMethod = .post
    var baseURL = URL(unsafeString: "https://elifessler.com/s2s/api/")
    var path: String = "gen2"
    var encoding: ParameterEncoding = URLEncoding.default
    var parameters: Parameters?
    var headers: [String: String]?

    init(accessToken: String, timestamp: Int, userAgent: String) {
        self.headers = [
            "User-Agent": userAgent,
        ]
        self.parameters = [
            "naIdToken": accessToken,
            "timestamp": String(timestamp),
        ]
    }

    internal struct Response: Codable {
        let hash: String
        let accessToken: String
        let timestamp: Int

        init(accessToken: String, timestamp: Int) {
            self.timestamp = timestamp
            self.accessToken = accessToken
            self.hash = getIkaHash(timestamp: timestamp, idToken: accessToken)
            print(hash)
        }
    }
}
