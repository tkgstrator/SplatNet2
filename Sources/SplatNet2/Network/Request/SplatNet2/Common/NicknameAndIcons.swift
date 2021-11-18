//
//  NicknameAndIcons.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

public class NicknameIcons: RequestType {
    public var baseURL = URL(unsafeString: "https://app.splatoon2.nintendo.net/api/")
    public var method: HTTPMethod = .get
    public var path: String = "nickname_and_icon"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = NicknameIcons.Response

    init(iksmSession: String?, playerId: [String]) {
        self.path = "nickname_and_icon?\(playerId.queryString)"
        self.headers = ["cookie": "iksm_session=\(iksmSession ?? "")"]
    }

    public struct Response: Codable {
        public var nicknameAndIcons: [NicknameIcon]

        public struct NicknameIcon: Codable {
            public var nickname: String
            public var nsaId: String
            public var thumbnailUrl: String
        }
    }
}

private extension Array where Element == String {
    var queryString: String {
        self.map { "id=\($0)" }.joined(separator: "&")
    }
}
