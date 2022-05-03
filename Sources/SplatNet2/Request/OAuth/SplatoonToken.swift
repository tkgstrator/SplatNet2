//
//  SplatoonToken.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation

internal class SplatoonToken: RequestType {
    typealias ResponseType = SplatoonToken.Response

    var method: HTTPMethod = .post
    var baseURL = URL(unsafeString: "https://api-lp1.znc.srv.nintendo.net/")
    var path: String = "v3/Account/Login"
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

//    internal struct Response: Codable {
//        var result: SplatoonTokenResult
//        var status: Int
//        var correlationId: String
//
//        struct SplatoonTokenResult: Codable {
//            var webApiServerCredential: WebAPIServerCredential
//            var user: WebAPIServerUser
//            var firebaseCredential: FirebaseCredential
//        }
//
//        struct WebAPIServerUser: Codable {
//            var name: String
//            var imageUri: String
//            var id: Int
//            var supportId: String
//            var membership: Membership
//        }
//
//        struct Membership: Codable {
//            var active: Bool
//        }
//
//        struct FirebaseCredential: Codable {
//            var expiresIn: Int
//            var accessToken: String
//        }
//
//        struct WebAPIServerCredential: Codable {
//            var expiresIn: Int
//            var accessToken: String
//        }
//    }

    // MARK: - Response
    public struct Response: Codable {
        public let status: Int
        public let result: Result
        public let correlationId: String
    }

    // MARK: - Result
    public struct Result: Codable {
        public let user: User
        public let webApiServerCredential, firebaseCredential: Credential
    }

    // MARK: - Credential
    public struct Credential: Codable {
        public let accessToken: String
        public let expiresIn: Int
    }

    // MARK: - User
    public struct User: Codable {
        public let id: Int
        public let nsaId: String
        public let imageUri: String
        public let name, supportId: String
        public let isChildRestricted: Bool
        public let etag: String
        public let links: Links
        public let permissions: Permissions
        public let presence: Presence
    }

    // MARK: - Links
    public struct Links: Codable {
        public let nintendoAccount: NintendoAccount
        public let friendCode: FriendCode
    }

    // MARK: - FriendCode
    public struct FriendCode: Codable {
        public let regenerable: Bool
        public let regenerableAt: Int
        public let id: String
    }

    // MARK: - NintendoAccount
    public struct NintendoAccount: Codable {
        public let membership: Membership
    }

    // MARK: - Membership
    public struct Membership: Codable {
        public let active: Bool
    }

    // MARK: - Permissions
    public struct Permissions: Codable {
        public let presence: String
    }

    // MARK: - Presence
    public struct Presence: Codable {
        public let state: String
        public let updatedAt, logoutAt: Int
        public let game: Game
    }

    // MARK: - Game
    public struct Game: Codable {
    }
}
