//
//  SessionToken.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//
//  swiftlint:disable discouraged_optional_collection

import Alamofire
import Foundation

internal class SessionToken: RequestType {
    typealias ResponseType = SessionToken.Response

    var method: HTTPMethod = .post
    var baseURL = URL(unsafeString: "https://accounts.nintendo.com/")
    var path: String = "connect/1.0.0/api/session_token"
    var parameters: Parameters?
    var headers: [String: String]?

    init(code: String, verifier: String) {
        self.parameters = [
            "client_id": "71b963c1b7b6d119",
            "session_token_code": code,
            "session_token_code_verifier": verifier,
        ]
    }

    internal struct Response: Codable {
        var sessionToken: String
    }
}
