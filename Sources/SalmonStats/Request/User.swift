//
//  User.swift
//  SalmonStats
//
//  Created by tkgstrator on 2021/04/17.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation
import SplatNet2
import SwiftUI

public class UserRequest: RequestType {
    public typealias ResponseType = UserRequest.Response

    // POSTかPUTか迷うところではあるが
    public var method: HTTPMethod = .post
    public var path: String = "users"
    public var encoding: ParameterEncoding = JSONEncoding.default
    public var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    public var headers: [String: String]?

    public init(uid: String, displayName: String?, screenName: String?, photoURL: String?, accounts: [Account]) {
        let parameters: [String: Any?] =  [
            "uid": uid,
            "display_name": displayName,
            "screen_name": screenName ?? "@Salmonia3",
            "thumbnail_url": photoURL,
            "accounts": accounts.map({ $0.asJSON(keyEncodingStragety: .convertToSnakeCase) })
        ]
        self.parameters = parameters.compactMapValues({ $0 })
    }

    public struct Account: Codable {
        public let nsaid: String
        public let nickname: String
        public let thumbnailUrl: String
        public let friendCode: String
    }

    public struct Response: Codable {
        public let id: Int
        public let isFriendCodePublic: Bool
        public let isImperialScholars: Bool
        public let isTwitterIdPublic: Bool
        public let isVerified: Bool
        public let name: String
        public let screenName: String
        public let thumbnailUrl: String
        public let uid: String
        public let accounts: [Account]
    }
}
