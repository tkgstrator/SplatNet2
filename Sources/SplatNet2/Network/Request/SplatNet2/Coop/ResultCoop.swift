//
//  ResultCoop.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

internal protocol IdName: Codable {
    var id: String { get }
    var name: String { get }
}

internal protocol KeyName: Codable {
    var key: String { get }
    var name: String { get }
}

public class ResultCoop: RequestType {
    public typealias ResponseType = ResultCoop.Response

    public var baseURL = URL(unsafeString: "https://app.splatoon2.nintendo.net/api/")
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String: String]?

    init(jobId: Int) {
        self.path = "coop_results/\(jobId)"
    }

    public struct Response: Codable {
        public var jobId: Int
        public var jobScore: Int
        public var jobRate: Int
        public var jobResult: JobResult
        public var schedule: Schedule
        public var kumaPoint: Int
        public var grade: Grade
        public var gradePoint: Int
        public var gradePointDelta: Int
        public var startTime: Int
        public var playTime: Int
        public var endTime: Int
        public var waveDetails: [WaveResult]
        public var dangerRate: Double
        public var bossCounts: [String: BossSalmonid]
        public var otherResults: [PlayerResult]
        public var myResult: PlayerResult

        public struct JobResult: Codable {
            public var failureReason: String?
            public var failureWave: Int?
            public var isClear: Bool

            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(failureReason, forKey: .failureReason)
                try container.encode(failureWave, forKey: .failureWave)
                try container.encode(isClear, forKey: .isClear)
            }
        }

        public struct Schedule: Codable {
            public var stage: Stage
            public var startTime: Int
            public var endTime: Int
            public var weapons: [WeaponList]
        }

        public struct Grade: Codable {
            public var id: String
            public var longName: String
            public var name: String
            public var shortName: String
        }

        public struct Stage: Codable {
            public var image: String
            public var name: String
            public var stageId: Int {
                switch image {
                    case "/images/coop_stage/65c68c6f0641cc5654434b78a6f10b0ad32ccdee.png":
                        return 5_000
                    case "/images/coop_stage/e07d73b7d9f0c64e552b34a2e6c29b8564c63388.png":
                        return 5_001
                    case "/images/coop_stage/6d68f5baa75f3a94e5e9bfb89b82e7377e3ecd2c.png":
                        return 5_002
                    case "/images/coop_stage/e9f7c7b35e6d46778cd3cbc0d89bd7e1bc3be493.png":
                        return 5_003
                    case "/images/coop_stage/50064ec6e97aac91e70df5fc2cfecf61ad8615fd.png":
                        return 5_004
                    default:
                        return 5_000
                }
            }
        }

        public struct WaveResult: Codable {
            public var eventType: KeyName
            public var waterLevel: KeyName
            public var goldenIkuraNum: Int
            public var goldenIkuraPopNum: Int
            public var quotaNum: Int
            public var ikuraNum: Int
        }

        public struct KeyName: Codable {
            public var key: String
            public var name: String
        }

        public struct BossSalmonid: Codable {
            public var boss: KeyName
            public var count: Int
        }

        public struct PlayerResult: Codable {
            public var bossKillCounts: [String: BossSalmonid]
            public var deadCount: Int
            public var helpCount: Int
            public var ikuraNum: Int
            public var goldenIkuraNum: Int
            public var special: Special
            public var specialCounts: [Int]
            public var weaponList: [WeaponList]
            public var playerType: PlayerType
            public var name: String
            public var pid: String
        }

        public struct Special: IdName, Codable {
            public var id: String
            public var name: String
        }

        public struct WeaponList: Codable {
            public var id: String
            public var weapon: Weapon?
            public var coopSpecialWeapon: CoopWeapon?
        }

        public struct Weapon: IdName, Codable {
            public var id: String
            public var name: String
            public var image: String
            public var thumbnail: String
        }

        public struct CoopWeapon: Codable {
            public var image: String
            public var name: String
        }

        public struct PlayerType: Codable {
            public var species: String
            public var style: String
        }
    }
}
