//
//  Result.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//

import Alamofire
import Foundation

public class Result: RequestType {
    public typealias ResponseType = Result.Response

    public var baseURL = URL(unsafeString: "https://app.splatoon2.nintendo.net/api/")
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String: String]?

    init(jobId: Int) {
        self.path = "coop_results/\(jobId)"
    }

    // MARK: - Result
    public struct Response: Codable {
        let jobScore: Int
        let playerType: PlayerType
        let grade: GradeType
        let otherResults: [PlayerResult]?
        let schedule: Schedule
        let kumaPoint: Int
        let waveDetails: [WaveDetail]
        let jobResult: JobResult
        let jobId, startTime: Int
        let myResult: PlayerResult
        let gradePointDelta, jobRate, endTime: Int
        let bossCounts: [String: BossCount]
        let gradePoint, playTime: Int
        let dangerRate: Double
    }

    // MARK: - BossCount
    struct BossCount: Codable {
        let boss: Boss
        let count: Int
    }

    // MARK: - Boss
    struct Boss: Codable {
        let name: BossName
        let key: BossKey
    }

    struct EventType: Codable {
        let name: EventName
        let key: EventKey
    }

    struct WaterLevel: Codable {
        let name: WaterName
        let key: WaterKey
    }

    enum BossKey: String, Codable {
        case sakediver = "sakediver"
        case sakedozer = "sakedozer"
        case sakelienBomber = "sakelien-bomber"
        case sakelienCupTwins = "sakelien-cup-twins"
        case sakelienGolden = "sakelien-golden"
        case sakelienShield = "sakelien-shield"
        case sakelienSnake = "sakelien-snake"
        case sakelienTower = "sakelien-tower"
        case sakerocket = "sakerocket"
    }

    enum EventKey: String, Codable {
        case cohockCharge = "cohock-charge"
        case fog = "fog"
        case goldieSeeking = "goldie-seeking"
        case griller = "griller"
        case rush = "rush"
        case theMothership = "the-mothership"
        case waterLevels = "water-levels"
    }

    enum WaterKey: String, Codable {
        case high
        case low
        case normal
    }

    enum BossName: String, Codable {
        case drizzler = "Drizzler"
        case flyfish = "Flyfish"
        case goldie = "Goldie"
        case maws = "Maws"
        case scrapper = "Scrapper"
        case steelEel = "Steel Eel"
        case steelhead = "Steelhead"
        case griller = "Griller"
        case stinger = "Stinger"
    }

    enum EventName: String, Codable {
        case rush = "Rush"
        case cohockCharge = "Cohock Charge"
        case waterLevels = "-"
        case goldieSeeking = "Goldie Seeking"
        case theGriller = "The Griller"
        case theMothership = "The Mothership"
        case fog = "Fog"
    }

    enum WaterName: String, Codable {
        case highTide = "High tide"
        case lowTide = "Low tide"
        case normal = "Normal"
    }

    // MARK: - Grade
    struct GradeType: Codable {
        let longName: GradeName?
        let id: String
        let shortName: GradeName?
        let name: GradeName
    }

    enum GradeName: String, Codable {
        case profreshional = "Profreshional"
        case overachiver = "Over achiver"
        case gogetter = "Go getter"
        case parttimer = "Part timer"
        case apparentice = "Apparentice"
        case intern = "Intern"
    }

    // MARK: - JobResult
    struct JobResult: Codable {
        let failureWave: Int?
        let isClear: Bool
        let failureReason: String?
    }

    // MARK: - PlayerResult
    struct PlayerResult: Codable {
        let pid: String
        let specialCounts: [Int]
        let goldenIkuraNum: Int
        let bossKillCounts: [String: BossCount]
        let special: SpecialType
        let deadCount: Int
        let name: String
        let ikuraNum: Int
        let playerType: PlayerType
        let helpCount: Int
        let weaponList: [WeaponList]
    }

    // MARK: - PlayerType
    struct PlayerType: Codable {
        let style: Style
        let species: Species
    }

    enum Species: String, Codable {
        case inklings
        case octlings
    }

    enum Style: String, Codable {
        case girl
        case boy
    }

    // MARK: - Special
    struct SpecialType: Codable {
        let imageB: ImageB
        let imageA: ImageA
        let name: SpecialName
        let id: String
    }

    enum ImageA: String, Codable {
        case inkjet = "/images/special/18990f646c551ee77c5b283ec814e371f692a553.png"
        case splashdown = "/images/special/324d41e9582d84101152849bc8c96d6595c9b0ff.png"
        case splatBombLauncher = "/images/special/7af300fdd872feb27b3d8e68a969457fac8b3bb7.png"
        case stingRay = "/images/special/9871c82952ed0141be0310ace1942c9f5f66d655.png"
    }

    enum ImageB: String, Codable {
        case inkjet = "/images/special/26e8117808ce17dadb0f23943359e5909fef4085.png"
        case splashdown = "/images/special/485b748720bbf809d8b28f9f4ee1a505cbcb339b.png"
        case splatBombLauncher = "/images/special/4eb81e00f5d707248879a7c7037d8475716a8045.png"
        case stingRay = "/images/special/9e89e1d67803c3021203182ecc7f38bc2c0f5400.png"
    }

    enum SpecialName: String, Codable {
        case inkjet = "Inkjet"
        case splashdown = "Splashdown"
        case splatBombLauncher = "Splat-Bomb Launcher"
        case stingRay = "Sting Ray"
    }

    // MARK: - WeaponListElement
    struct WeaponList: Codable {
        let id: String
        let weapon: Brand?
        let coopSpecialWeapon: Brand?
    }

    // MARK: - Brand
    struct Brand: Codable {
        let id, thumbnail: String?
        let image, name: String
    }

    // MARK: - Schedule
    struct Schedule: Codable {
        let stage: Stage
        let weapons: [WeaponList]
        let endTime, startTime: Int
    }

    // MARK: - Stage
    struct Stage: Codable {
        let name: StageName
        let image: String
    }

    enum StageName: String, Codable {
        case shakeship = "Marooner's Bay"
        case shakeride = "Ruins of Ark Polaris"
        case shakelift = "Salmonid Smokeyard"
        case shakeup = "Spawning Grounds"
        case shakehouse = "Lost Outpost"
    }

    // MARK: - WaveDetail
    struct WaveDetail: Codable {
        let quotaNum, goldenIkuraPopNum: Int
        let waterLevel: WaterLevel
        let ikuraNum, goldenIkuraNum: Int
        let eventType: EventType
    }
}
