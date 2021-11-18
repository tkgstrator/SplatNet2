//
//  SplatNet2.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.

import Alamofire
import Combine
import Foundation

public extension SplatNet2 {
    // 変換用のクラス
    class Coop {
        public class Result: Codable {
            /// バイトID
            public var jobId: Int
            /// ステージID
            public var stageId: Int
            /// バイトスコア
            public var jobScore: Int?
            /// バイトレート
            public var jobRate: Int?
            /// リザルト
            public var jobResult: ResultJob
            /// キケン度
            public var dangerRate: Double
            /// スケジュール
            public var schedule: Schedule
            /// 獲得クマポイント
            public var kumaPoint: Int?
            /// ウデマエ
            public var grade: Int?
            /// 評価レート
            public var gradePoint: Int?
            /// 評価レート増減
            public var gradePointDelta: Int?
            /// 時間
            public var time: ResultTime
            /// オオモノ出現数
            public var bossCounts: [Int]
            /// オオモノ討伐数
            public var bossKillCounts: [Int]
            /// プレイヤーリザルト
            public var results: [ResultPlayer]
            /// WAVE内容
            public var waveDetails: [ResultWave]
            /// 獲得金イクラ数
            public var goldenEggs: Int
            /// 獲得赤イクラ数
            public var powerEggs: Int

            internal init(from response: ResultCoop.Response) {
                self.jobId = response.jobId
                self.stageId = response.schedule.stage.stageId
                self.jobScore = response.jobScore
                self.jobRate = response.jobRate
                self.jobResult = ResultJob(from: response.jobResult)
                self.dangerRate = response.dangerRate
                self.schedule = Schedule(from: response.schedule)
                self.kumaPoint = response.kumaPoint
                self.grade = Int(response.grade.id)!
                self.gradePoint = response.gradePoint
                self.gradePointDelta = response.gradePointDelta
                self.time = ResultTime(from: response)
                self.bossCounts = response.bossCounts.sorted(by: { Int($0.key)! < Int($1.key)! }).map { $0.value.count }
                var results: [ResultCoop.Response.PlayerResult] = [response.myResult]
                results.append(contentsOf: response.otherResults)
                self.results = results.map { ResultPlayer(from: $0) }
                self.waveDetails = response.waveDetails.map { ResultWave(from: $0) }
                var tmpKillCounts = Array(repeating: 0, count: 9)
                for result in self.results {
                    tmpKillCounts = Array(zip(tmpKillCounts, result.bossKillCounts)).map { $0.0 + $0.1 }
                }
                self.bossKillCounts = tmpKillCounts
                self.goldenEggs = response.waveDetails.map { $0.goldenIkuraNum }.reduce(0, +)
                self.powerEggs = response.waveDetails.map { $0.ikuraNum }.reduce(0, +)
            }
        }

        public class ResultTime: Codable {
            public var playTime: Int
            public var startTime: Int
            public var endTime: Int

            internal init(from response: ResultCoop.Response) {
                self.startTime = response.startTime
                self.endTime = response.endTime
                self.playTime = response.playTime
            }
        }
        public class ResultJob: Codable {
            public var failureReason: String?
            public var failureWave: Int?
            public var isClear = false

            internal init(from response: ResultCoop.Response.JobResult) {
                self.failureWave = response.failureWave
                self.failureReason = response.failureReason
                self.isClear = response.isClear
            }
        }

        public class Schedule: Codable {
            public var startTime: Int
            public var endTime: Int
            public var weaponList: [Int]
            public var stageId: Int

            internal init(from response: ResultCoop.Response.Schedule) {
                self.startTime = response.startTime
                self.endTime = response.endTime
                self.weaponList = response.weapons.compactMap { Int($0.id) }
                self.stageId = response.stage.stageId
            }
        }

        public class ResultPlayer: Codable {
            public var bossKillCounts: [Int]
            public var helpCount: Int
            public var deadCount: Int
            public var ikuraNum: Int
            public var goldenIkuraNum: Int
            public var pid: String
            public var name: String?
            public var playerType: PlayerType
            public var specialId: Int
            public var specialCounts: [Int]
            public var weaponList: [Int]

            internal init(from response: ResultCoop.Response.PlayerResult) {
                // swiftlint:disable:next force_unwrapping
                self.bossKillCounts = response.bossKillCounts.sorted(by: { Int($0.key)! < Int($1.key)! }).map { $0.value.count }
                self.helpCount = response.helpCount
                self.deadCount = response.deadCount
                self.ikuraNum = response.ikuraNum
                self.goldenIkuraNum = response.goldenIkuraNum
                self.pid = response.pid
                self.name = response.name
                self.playerType = PlayerType(from: response.playerType)
                // swiftlint:disable:next force_unwrapping
                self.specialId = Int(response.special.id)!
                self.specialCounts = response.specialCounts
                self.weaponList = response.weaponList.compactMap { Int($0.id) }
            }
        }

        public class PlayerType: Codable {
            public var species: String
            public var style: String

            internal init(from response: ResultCoop.Response.PlayerType) {
                self.species = response.species
                self.style = response.style
            }
        }

        public class ResultWave: Codable {
            public var eventType: EventType
            public var waterLevel: WaterLevel
            public var ikuraNum: Int
            public var goldenIkuraNum: Int
            public var goldenIkuraPopNum: Int
            public var quotaNum: Int

            internal init(from response: ResultCoop.Response.WaveResult) {
                // swiftlint:disable:next force_unwrapping
                self.eventType = EventType(rawValue: response.eventType.key)!
                // swiftlint:disable:next force_unwrapping
                self.waterLevel = WaterLevel(rawValue: response.waterLevel.key)!
                self.ikuraNum = response.ikuraNum
                self.goldenIkuraNum = response.goldenIkuraNum
                self.goldenIkuraPopNum = response.goldenIkuraPopNum
                self.quotaNum = response.quotaNum
            }
        }
    }
}

public enum EventType: String, CaseIterable, Codable {
    case noevent = "water-levels"
    case rush = "rush"
    case goldie = "goldie-seeking"
    case griller = "griller"
    case mothership = "the-mothership"
    case fog = "fog"
    case cohock = "cohock-charge"

    var eventType: Int {
        switch self {
        case .noevent:
            return 0
        case .rush:
            return 1
        case .goldie:
            return 2
        case .griller:
            return 3
        case .mothership:
            return 4
        case .fog:
            return 5
        case .cohock:
            return 6
        }
    }
}

public enum WaterLevel: String, CaseIterable, Codable {
    case low
    case normal
    case high

    var waterLevel: Int {
        switch self {
        case .low:
            return 0
        case .normal:
            return 1
        case .high:
            return 2
        }
    }
}
