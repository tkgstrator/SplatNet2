//
//  ResultWave.swift
//
//
//  Created by devonly on 2022/03/14.
//

import Alamofire
import Common
import Foundation
import SplatNet2

public class ResultWave: RequestType {
    public typealias ResponseType = Response

    //  swiftlint:disable:next discouraged_optional_collection
    public var headers: [String: String]?
    public var parameters: Parameters?
    public let method: HTTPMethod = .get
#if DEBUG
//    public let baseURL = URL(unsafeString: "https://lanplay.splatnet2.com/api/")
    public let baseURL = URL(unsafeString: "http://localhost:3000/api")
#else
    public let baseURL = URL(unsafeString: "https://lanplay.splatnet2.com/api/")
#endif
    public let path: String
    public let encoding: ParameterEncoding = URLEncoding.default

    init(startTime: Int) {
        self.path = "waves/\(startTime)"
    }
    
    public struct Response: Codable {
        public let results: [CoopResultWave]
    }

    public struct CoopResultWave: Codable {
        public let eventType: EventId
        public let waterLevel: WaterId
        public let distribution: [Distribution]
    }

    public struct Distribution: Codable {
        public let goldenIkuraNum: Int
        public let count: Int
    }
}
