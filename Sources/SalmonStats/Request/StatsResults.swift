//
//  ResultsStats.swift
//  SalmonStats
//
//  Created by tkgstrator on 2021/04/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation

public class StatsResults: RequestType {
    public typealias ResponseType = StatsResults.Response
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String: String]?
    public var encoding: ParameterEncoding = URLEncoding.default

    init(nsaid: String, pageId: Int, count: Int = 50) {
        self.parameters = [
            "raw": 0,
            "count": count,
            "page": pageId,
        ]
        self.path = "players/\(nsaid)/results"
    }

    public struct Response: Codable {
        public var currentPage: Int
        public var lastPage: Int
        public var results: [StatsResult.Response]
    }
}
