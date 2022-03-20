//
//  NicknameIcons.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation

public class NicknameIcons: RequestType {
    public typealias ResponseType = NicknameIcons.Response

    public var method: HTTPMethod = .get
    public var path: String = "nickname_and_icon"
    public var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    public var headers: [String: String]?

    init(playerId: [String]) {
        self.path = "nickname_and_icon?\(playerId.queryString)"
    }

    public struct Response: Codable {
        public var nicknameAndIcons: [NicknameIcon]

        public struct NicknameIcon: Codable {
            public var nickname: String
            public var nsaId: String
            public var thumbnailUrl: URL

            enum CodingKeys: String, CodingKey {
                case nickname
                case nsaId
                case thumbnailUrl
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                self.nickname = try container.decode(String.self, forKey: .nickname)
                self.nsaId = try container.decode(String.self, forKey: .nsaId)
                self.thumbnailUrl = URL(unsafeString: try container.decode(String.self, forKey: .thumbnailUrl))
            }
        }
    }
}

private extension Array where Element == String {
    var queryString: String {
        self.map { "id=\($0)" }.joined(separator: "&")
    }
}
