//
//  UploadWave.swift
//  
//
//  Created by devonly on 2022/03/14.
//

import Alamofire
import Common
import Foundation
import SplatNet2

public class UploadWave: RequestType {
    public typealias ResponseType = Response

    //  swiftlint:disable:next discouraged_optional_collection
    public var headers: [String: String]?
    public var parameters: Parameters?
    public let method: HTTPMethod = .post
#if DEBUG
//    public let baseURL = URL(unsafeString: "https://lanplay.splatnet2.com/api/")
    public let baseURL = URL(unsafeString: "http://localhost:3000/api")
#else
    public let baseURL = URL(unsafeString: "https://lanplay.splatnet2.com/api/")
#endif
    public let path: String = "waves"
    public let encoding: ParameterEncoding = JSONEncoding.default

    init(_ results: [CoopResult.Response]) {
        // リクエストを生成
        let results: [Request] = results.flatMap({ result -> [Request] in
            let waves: [CoopResult.WaveDetail] = result.waveDetails
            let startTime: Int = result.startTime
            let playTime: Int = result.playTime
            let members: [String] = result.playerResults.map({ $0.pid })
            let failureWave: Int? = result.jobResult.failureWave
            return waves.map({ wave -> Request in
                let isClear: Bool = failureWave != waves.firstIndex(of: wave)
                return Request(playTime: playTime, startTime: startTime, result: wave, members: members, isClear: isClear, waveNum: waves.firstIndex(of: wave))
            })
        })
        self.parameters = ["results": results.map({ $0.asJSON() })]
    }

    public struct Request: Codable {
        public let startTime: Int
        public let playTime: Int
        public let ikuraNum: Int
        public let goldenIkuraNum: Int
        public let goldenIkuraPopNum: Int
        public let eventType: EventId
        public let waterLevel: WaterId
        public let quotaNum: Int
        public let isClear: Bool
        public let waveNum: Int?
        public let members: [String]

        init(playTime: Int, startTime: Int, result: CoopResult.WaveDetail, members: [String], isClear: Bool, waveNum: Int?) {
            self.playTime = playTime
            self.startTime = startTime
            self.ikuraNum = result.ikuraNum
            self.goldenIkuraNum = result.goldenIkuraNum
            self.goldenIkuraPopNum = result.goldenIkuraPopNum
            self.eventType = result.eventType.rawValue
            self.waterLevel = result.waterLevel.rawValue
            self.quotaNum = result.quotaNum
            self.members = members
            self.isClear = isClear
            self.waveNum = waveNum
        }
    }

    public struct Response: Codable {
        public let results: [UploadWaveResult]
    }

    public struct UploadWaveResult: Codable {
        public let waveId: Int?
        public let created: Bool
    }

//    public struct Response: Codable {
//        public let results: [CoopResultWave]
//    }
//
//    public struct CoopResultWave: Codable {
//        public let eventType: EventId
//        public let waterLevel: WaterId
//        public let distribution: [Distribution]
//    }
//
//    public struct Distribution: Codable {
//        public let goldenIkuraNum: Int
//        public let count: Int
//    }
}
