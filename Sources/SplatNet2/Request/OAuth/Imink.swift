//
//  Imink.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation

internal class Imink: RequestType {
    typealias ResponseType = Imink.Response

    var method: HTTPMethod = .post
    var baseURL = URL(unsafeString: "https://api.imink.app")
    var path: String = "f"
    var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]?

    init(accessToken: String, timestamp: UInt64, type: IminkType) {
        self.parameters = [
            "token": accessToken,
            "timestamp": String(timestamp),
            "request_id": "00000000-0000-0000-0000-000000000000",
            "hash_method": String(type.rawValue),
        ]
    }

    enum IminkType: Int, CaseIterable {
        case app = 2
        case nso = 1
    }

    internal struct Response: Codable {
        let f: String
    }
}
