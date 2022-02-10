//
//  FlapgToken.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

internal class FlapgToken: RequestType {
    typealias ResponseType = FlapgToken.Response

    var method: HTTPMethod = .get
    var baseURL = URL(unsafeString: "https://flapg.com/")
    var path: String = "ika2/api/login"
    var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]?

    init(accessToken: String, timestamp: Int, hash: String, type: FlapgType) {
        self.headers = [
            "x-token": accessToken,
            "x-time": String(timestamp),
            "x-guid": "037239ef-1914-43dc-815d-178aae7d8934",
            "x-hash": hash,
            "x-ver": "3",
            "x-iid": type.rawValue,
        ]
    }

//    init(response: IkaHash.Response, type: FlapgType) {
//        self.headers = [
//            "x-token": response.accessToken,
//            "x-time": String(response.timestamp),
//            "x-guid": "037239ef-1914-43dc-815d-178aae7d8934",
//            "x-hash": response.hash,
//            "x-ver": "3",
//            "x-iid": type.rawValue,
//        ]
//    }

    enum FlapgType: String, CaseIterable {
        case app
        case nso
    }

    internal struct Response: Codable {
        var result: FlapgParameters

        struct FlapgParameters: Codable {
            var f: String
            var p1: String
            var p2: String
            var p3: String
        }
    }
}
