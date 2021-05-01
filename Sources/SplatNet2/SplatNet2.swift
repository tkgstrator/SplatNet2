import Foundation
import Alamofire
import Combine

public extension SplatNet2 {
    // 変換用のクラス
    public class Coop {
        public struct Result: Codable {
            var jobId: Int
            var stageId: Int
            var jobScore: Int
            var jobRate: Int
            var jobResult: ResultJob
            var dangerRate: Double
            var schedule: Schedule
            var kumaPoint: Int
            var grade: Int
            var gradePoint: Int
            var gradePointDelta: Int
            var time: ResultTime
            var bossCounts: [Int]
            var bossKillCounts: [Int]
            var results: [ResultPlayer]
            var waveDetails: [ResultWave]

            init(from response: Response.ResultCoop) {
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
                self.bossCounts = response.bossCounts.map { $0.value.count }
                var results: [Response.ResultCoop.PlayerResult] = [response.myResult]
                results.append(contentsOf: response.otherResults)
                self.results = results.map { ResultPlayer(from: $0) }
                self.waveDetails = response.waveDetails.map { ResultWave(from: $0) }
                var tmpKillCounts = Array(repeating: 0, count: 9)
                for result in self.results {
                    tmpKillCounts = Array(zip(tmpKillCounts, result.bossKillCounts)).map { $0.0 + $0.1 }
                }
                self.bossKillCounts = tmpKillCounts
            }
        }

        struct ResultTime: Codable {
            var playTime: String
            var startTime: String
            var endTime: String

            init(from response: Response.ResultCoop) {
                let formatter: ISO8601DateFormatter = {
                    let formatter = ISO8601DateFormatter()
                    formatter.timeZone = TimeZone.current
                    return formatter
                }()

                self.startTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(response.startTime)))
                self.endTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(response.endTime)))
                self.playTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(response.playTime)))
            }
        }
        struct ResultJob: Codable {
            var failureReason: Bool?
            var failureWave: Int?
            var isClear: Bool

            init(from response: Response.ResultCoop.JobResult) {
                self.failureWave = response.failureWave
                self.failureWave = response.failureWave
                self.isClear = response.isClear
            }
        }

        struct Schedule: Codable {
            var startTime: String
            var endTime: String
            var weaponList: [Int]
            var stageId: Int

            init(from response: Response.ResultCoop.Schedule) {
                let formatter: ISO8601DateFormatter = {
                    let formatter = ISO8601DateFormatter()
                    formatter.timeZone = TimeZone.current
                    return formatter
                }()

                self.startTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(response.startTime)))
                self.endTime = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(response.endTime)))
                self.weaponList = response.weapons.map { Int($0.id)! }
                self.stageId = response.stage.stageId
            }
        }

        struct ResultPlayer: Codable {
            var bossKillCounts: [Int]
            var helpCount: Int
            var deadCount: Int
            var ikuraNum: Int
            var goldenIkuraNum: Int
            var pid: String
            var name: String
            var playerType: PlayerType
            var specialId: Int
            var specialCounts: [Int]
            var weaponList: [Int]

            init(from response: Response.ResultCoop.PlayerResult) {
                self.bossKillCounts = response.bossKillCounts.map { $0.value.count }
                self.helpCount = response.helpCount
                self.deadCount = response.deadCount
                self.ikuraNum = response.ikuraNum
                self.goldenIkuraNum = response.goldenIkuraNum
                self.pid = response.pid
                self.name = response.name
                self.playerType = PlayerType(from: response.playerType)
                self.specialId = Int(response.special.id)!
                self.specialCounts = response.specialCounts
                self.weaponList = response.weaponList.map { Int($0.weapon.id)! }
            }
        }

        struct PlayerType: Codable {
            var species: String
            var style: String

            init(from response: Response.ResultCoop.PlayerType) {
                self.species = response.species
                self.style = response.style
            }
        }

        struct ResultWave: Codable {
            var eventType: Int
            var waterLevel: Int
            var ikuraNum: Int
            var goldenIkuraNum: Int
            var goldenIkuraPopNum: Int
            var quotaNum: Int

            init(from response: Response.ResultCoop.WaveResult) {
                self.eventType = EventType(rawValue: response.eventType.key)!.eventType
                self.waterLevel = WaterLevel(rawValue: response.waterLevel.key)!.waterLevel
                self.ikuraNum = response.ikuraNum
                self.goldenIkuraNum = response.goldenIkuraNum
                self.goldenIkuraPopNum = response.goldenIkuraPopNum
                self.quotaNum = response.quotaNum
            }
        }

        enum EventType: String, CaseIterable {
            case noevent = "water-levels"
            case rush = "rush"
            case goldie = "goldie-seeking"
            case griller = "griller"
            case mothership = "the-mothership"
            case fog = "fog"
            case cohock = "cohock-charge"
        }

        enum WaterLevel: String, CaseIterable {
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
