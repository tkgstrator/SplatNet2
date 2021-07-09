import Foundation
import Alamofire
import Combine

public extension SplatNet2 {
    // 変換用のクラス
    class Coop {
        public struct Result: Codable {
            public var jobId: Int
            public var stageId: Int
            public var jobScore: Int?
            public var jobRate: Int?
            public var jobResult: ResultJob
            public var dangerRate: Double
            public var schedule: Schedule
            public var kumaPoint: Int?
            public var grade: Int?
            public var gradePoint: Int?
            public var gradePointDelta: Int?
            public var time: ResultTime
            public var bossCounts: [Int]
            public var bossKillCounts: [Int]
            public var results: [ResultPlayer]
            public var waveDetails: [ResultWave]
            public var goldenEggs: Int
            public var powerEggs: Int

            internal init(from response: Response.ResultCoop) {
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
                self.bossCounts = response.bossCounts.sorted(by: { Int($0.key)! < Int($1.key)!}).map { $0.value.count }
                var results: [Response.ResultCoop.PlayerResult] = [response.myResult]
                results.append(contentsOf: response.otherResults)
                self.results = results.map { ResultPlayer(from: $0) }
                self.waveDetails = response.waveDetails.map { ResultWave(from: $0) }
                var tmpKillCounts = Array(repeating: 0, count: 9)
                for result in self.results {
                    tmpKillCounts = Array(zip(tmpKillCounts, result.bossKillCounts)).map { $0.0 + $0.1 }
                }
                self.bossKillCounts = tmpKillCounts
                self.goldenEggs = response.waveDetails.map{ $0.goldenIkuraNum }.reduce(0, +)
                self.powerEggs = response.waveDetails.map{ $0.ikuraNum }.reduce(0, +)
            }
        }

        public struct ResultTime: Codable {
            public var playTime: Int
            public var startTime: Int
            public var endTime: Int

            internal init(from response: Response.ResultCoop) {
                self.startTime = response.startTime
                self.endTime = response.endTime
                self.playTime = response.playTime
            }
        }
        public struct ResultJob: Codable {
            public var failureReason: String?
            public var failureWave: Int?
            public var isClear: Bool

            internal init(from response: Response.ResultCoop.JobResult) {
                self.failureWave = response.failureWave
                self.failureReason = response.failureReason
                self.isClear = response.isClear
            }
        }

        public struct Schedule: Codable {
            public var startTime: Int
            public var endTime: Int
            public var weaponList: [Int]
            public var stageId: Int

            internal init(from response: Response.ResultCoop.Schedule) {
                self.startTime = response.startTime
                self.endTime = response.endTime
                self.weaponList = response.weapons.map { Int($0.id)! }
                self.stageId = response.stage.stageId
            }
        }

        public struct ResultPlayer: Codable {
            public var bossKillCounts: [Int]
            public var helpCount: Int
            public var deadCount: Int
            public var ikuraNum: Int
            public var goldenIkuraNum: Int
            public var pid: String
            public var name: String
            public var playerType: PlayerType
            public var specialId: Int
            public var specialCounts: [Int]
            public var weaponList: [Int]

            internal init(from response: Response.ResultCoop.PlayerResult) {
                self.bossKillCounts = response.bossKillCounts.sorted(by: { Int($0.key)! < Int($1.key)!}).map { $0.value.count }
                self.helpCount = response.helpCount
                self.deadCount = response.deadCount
                self.ikuraNum = response.ikuraNum
                self.goldenIkuraNum = response.goldenIkuraNum
                self.pid = response.pid
                self.name = response.name
                self.playerType = PlayerType(from: response.playerType)
                self.specialId = Int(response.special.id)!
                self.specialCounts = response.specialCounts
                self.weaponList = response.weaponList.map { Int($0.id)! }
            }
        }

        public struct PlayerType: Codable {
            public var species: String
            public var style: String

            internal init(from response: Response.ResultCoop.PlayerType) {
                self.species = response.species
                self.style = response.style
            }
        }

        public struct ResultWave: Codable {
            public var eventType: Int
            public var waterLevel: Int
            public var ikuraNum: Int
            public var goldenIkuraNum: Int
            public var goldenIkuraPopNum: Int
            public var quotaNum: Int

            internal init(from response: Response.ResultCoop.WaveResult) {
                self.eventType = EventType(rawValue: response.eventType.key)!.eventType
                self.waterLevel = WaterLevel(rawValue: response.waterLevel.key)!.waterLevel
                self.ikuraNum = response.ikuraNum
                self.goldenIkuraNum = response.goldenIkuraNum
                self.goldenIkuraPopNum = response.goldenIkuraPopNum
                self.quotaNum = response.quotaNum
            }
        }

        internal enum EventType: String, CaseIterable {
            case noevent = "water-levels"
            case rush = "rush"
            case goldie = "goldie-seeking"
            case griller = "griller"
            case mothership = "the-mothership"
            case fog = "fog"
            case cohock = "cohock-charge"
        }

        internal enum WaterLevel: String, CaseIterable {
            case low = "low"
            case normal = "normal"
            case high = "high"
        }
    }
}

extension SplatNet2.Coop.EventType {
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

extension SplatNet2.Coop.WaterLevel {
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
