//
//  FriendList.swift
//  SplatNet2
//
//  Created by tkgstrator on 2022/03/31.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation
import Common
import Alamofire

public class FriendList: RequestType {
    public typealias ResponseType = FriendList.Response

    public var method: HTTPMethod = .post
    public var baseURL: URL = URL(unsafeString: "https://api-lp1.znc.srv.nintendo.net/")
    public var path: String = "v3/Friend/List"
    public var parameters: Parameters? = [
        "requestId":"A6AAFDA0-E23B-45EA-83B7-1211ECA1404E",
        "parameter": [:]
    ]
    
    //  swiftlint:disable:next discouraged_optional_collection
    public var headers: [String: String]?

    init(splatoonToken: String) {
        self.headers = [
            "Authorization": "Bearer \(splatoonToken)",
        ]
    }

    // MARK: - Response
    public struct Response: Codable {
        public let status: Int
        public let result: Result
        public let correlationId: String
    }

    // MARK: - Result
    public struct Result: Codable {
        public let friends: [Friend]
    }

    // MARK: - Friend
    public struct Friend: Codable {
        public let id: Int
        public let nsaId: String
        public let imageUri: String
        public let name: String
        public let isFriend, isFavoriteFriend, isServiceUser: Bool
        public let friendCreatedAt: Int
        public let presence: Presence
    }

    // MARK: - Presence
    public struct Presence: Codable {
        public let state: State
        public let updatedAt, logoutAt: Int
        public let game: Game
    }

    // MARK: - Game
    public struct Game: Codable {
        public let name: String?
        public let imageUri, shopUri: String?
        public let totalPlayTime, firstPlayedAt: Int?
        public let sysDescription: String?
    }

    public enum State: String, Codable {
        case inactive   = "INACTIVE"
        case offline    = "OFFLINE"
        case online     = "ONLINE"
        case playing    = "PLAYING"
    }
}
