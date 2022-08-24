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
    var baseURL = URL(unsafeString: "https://s2s-hash-server.herokuapp.com/")
    var path: String = "hash"
    var encoding: ParameterEncoding = JSONEncoding.default
    var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]?

    init(accessToken: String, timestamp: UInt64) {
        self.parameters = [
            "naIdToken": accessToken,
            "timestamp": timestamp,
        ]
    }

    internal struct Response: Codable {
        let hash: String
        let naIdToken: String
        let timestamp: Int
    }
}
