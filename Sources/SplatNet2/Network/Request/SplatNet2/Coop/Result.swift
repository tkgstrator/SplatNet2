//
//  Result.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CodableDictionary
import Foundation

public class Result: RequestType {
    public typealias ResponseType = Result.Response

    public var baseURL = URL(unsafeString: "https://app.splatoon2.nintendo.net/api/")
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    public var headers: [String: String]?

    init(resultId: Int) {
        self.path = "coop_results/\(resultId)"
    }

    // MARK: - Result
    public struct Response: Codable {
        public let jobScore: Int?
        public let playerType: PlayerType?
        public let grade: GradeType?
        //  swiftlint:disable:next discouraged_optional_collection
        public let otherResults: [PlayerResult]?
        public let schedule: Schedule
        public let kumaPoint: Int?
        public let waveDetails: [WaveDetail]
        public let jobResult: JobResult
        public let jobId: Int?
        public let myResult: PlayerResult
        public let gradePointDelta: Int?
        public let jobRate: Int?
        public let startTime, playTime, endTime: Int
        public let bossCounts: CodableDictionary<BossId, BossCount>
        public let gradePoint: Int?
        public let dangerRate: Double

        public init(jobScore: Int?, playerType: Result.PlayerType?, grade: Result.GradeType?, otherResults: [Result.PlayerResult]?, schedule: Result.Schedule, kumaPoint: Int?, waveDetails: [Result.WaveDetail], jobResult: Result.JobResult, jobId: Int?, myResult: Result.PlayerResult, gradePointDelta: Int?, jobRate: Int?, startTime: Int, playTime: Int, endTime: Int, bossCounts: CodableDictionary<BossId, BossCount>, gradePoint: Int?, dangerRate: Double) {
            self.jobScore = jobScore
            self.playerType = playerType
            self.grade = grade
            self.otherResults = otherResults
            self.schedule = schedule
            self.kumaPoint = kumaPoint
            self.waveDetails = waveDetails
            self.jobResult = jobResult
            self.jobId = jobId
            self.myResult = myResult
            self.gradePointDelta = gradePointDelta
            self.jobRate = jobRate
            self.startTime = startTime
            self.playTime = playTime
            self.endTime = endTime
            self.bossCounts = bossCounts
            self.gradePoint = gradePoint
            self.dangerRate = dangerRate
        }
    }

    // MARK: - BossCount
    public struct BossCount: Codable {
        public let boss: Boss
        public let count: Int

        public init(boss: Result.Boss, count: Int) {
            self.boss = boss
            self.count = count
        }
    }

    // MARK: - Boss
    public struct Boss: Codable {
        public let name: String
        public let key: BossKey

        public init(name: String, key: Result.BossKey) {
            self.name = name
            self.key = key
        }
    }

    public enum BossId: String, Codable, CaseIterable, CodableDictionaryKey {
        case goldie = "3"
        case steelhead = "6"
        case flyfish = "9"
        case scrapper = "12"
        case steelEel = "13"
        case stinger = "14"
        case maws = "15"
        case griller = "16"
        case drizzler = "21"
    }

    public struct EventType: Codable {
        public let name: String
        public let key: EventKey

        public init(name: String, key: Result.EventKey) {
            self.name = name
            self.key = key
        }
    }

    public struct WaterLevel: Codable {
        public let name: String
        public let key: WaterKey

        public init(name: String, key: Result.WaterKey) {
            self.name = name
            self.key = key
        }
    }

    public enum BossKey: String, Codable, CaseIterable {
        case sakelienGolden = "sakelien-golden"
        case sakelienBomber = "sakelien-bomber"
        case sakelienCupTwins = "sakelien-cup-twins"
        case sakelienShield = "sakelien-shield"
        case sakelienSnake = "sakelien-snake"
        case sakelienTower = "sakelien-tower"
        case sakedozer = "sakedozer"
        case sakediver = "sakediver"
        case sakerocket = "sakerocket"
    }

    public enum EventKey: String, Codable, CaseIterable {
        case waterLevels = "water-levels"
        case rush = "rush"
        case goldieSeeking = "goldie-seeking"
        case griller = "griller"
        case fog = "fog"
        case theMothership = "the-mothership"
        case cohockCharge = "cohock-charge"
    }

    public enum WaterKey: String, Codable, CaseIterable {
        case high
        case low
        case normal
    }

    public enum FailureReason: String, Codable, CaseIterable {
        case wipeOut = "wipe_out"
        case timeLimit = "time_limit"
    }

    // MARK: - Grade
    public struct GradeType: Codable {
        public let longName: String?
        public let id: GradeId
        public let shortName: String?
        public let name: String

        public init(longName: String?, id: GradeId, shortName: String?, name: String) {
            self.longName = longName
            self.id = id
            self.shortName = shortName
            self.name = name
        }
    }

    public enum GradeId: String, Codable, CaseIterable {
        case profreshional = "5"
        case overachiver = "4"
        case gogetter = "3"
        case parttimer = "2"
        case apparentice = "1"
        case intern = "0"
    }

    // MARK: - JobResult
    public struct JobResult: Codable {
        @NullCodable public var failureWave: Int?
        public let isClear: Bool
        @NullCodable public var failureReason: FailureReason?

        public init(failureWave: Int?, isClear: Bool, failureReason: FailureReason?) {
            self.failureWave = failureWave
            self.isClear = isClear
            self.failureReason = failureReason
        }
    }

    // MARK: - PlayerResult
    public struct PlayerResult: Codable {
        public let pid: String
        public let specialCounts: [Int]
        public let goldenIkuraNum: Int
        public let bossKillCounts: CodableDictionary<BossId, BossCount>
        public let special: SpecialType
        public let deadCount: Int
        public let name: String?
        public let ikuraNum: Int
        public let playerType: PlayerType?
        public let helpCount: Int
        public let weaponList: [WeaponList]

        public init(pid: String, specialCounts: [Int], goldenIkuraNum: Int, bossKillCounts: CodableDictionary<BossId, BossCount>, special: Result.SpecialType, deadCount: Int, name: String?, ikuraNum: Int, playerType: Result.PlayerType?, helpCount: Int, weaponList: [Result.WeaponList]) {
            self.pid = pid
            self.specialCounts = specialCounts
            self.goldenIkuraNum = goldenIkuraNum
            self.bossKillCounts = bossKillCounts
            self.special = special
            self.deadCount = deadCount
            self.name = name
            self.ikuraNum = ikuraNum
            self.playerType = playerType
            self.helpCount = helpCount
            self.weaponList = weaponList
        }
    }

    // MARK: - PlayerType
    public struct PlayerType: Codable {
        public let style: Style
        public let species: Species
    }

    public enum Species: String, Codable, CaseIterable {
        case inklings
        case octlings
    }

    public enum Style: String, Codable, CaseIterable {
        case girl
        case boy
    }

    // MARK: - Special
    public struct SpecialType: Codable {
        public let imageA: ImageA
        public let imageB: ImageB
        public let name: String
        public let id: SpecialId

        public init(imageA: Result.ImageA, imageB: Result.ImageB, name: String, id: SpecialId) {
            self.imageA = imageA
            self.imageB = imageB
            self.name = name
            self.id = id
        }
    }

    public enum ImageA: String, Codable, CaseIterable {
        case inkjet = "/images/special/18990f646c551ee77c5b283ec814e371f692a553.png"
        case splashdown = "/images/special/324d41e9582d84101152849bc8c96d6595c9b0ff.png"
        case splatBombLauncher = "/images/special/7af300fdd872feb27b3d8e68a969457fac8b3bb7.png"
        case stingRay = "/images/special/9871c82952ed0141be0310ace1942c9f5f66d655.png"
    }

    public enum ImageB: String, Codable, CaseIterable {
        case inkjet = "/images/special/26e8117808ce17dadb0f23943359e5909fef4085.png"
        case splashdown = "/images/special/485b748720bbf809d8b28f9f4ee1a505cbcb339b.png"
        case splatBombLauncher = "/images/special/4eb81e00f5d707248879a7c7037d8475716a8045.png"
        case stingRay = "/images/special/9e89e1d67803c3021203182ecc7f38bc2c0f5400.png"
    }

    public enum SpecialId: String, Codable, CaseIterable {
        case splatBombLauncher = "2"
        case stingRay = "7"
        case inkjet = "8"
        case splashdown = "9"
    }

    // MARK: - WeaponList
    public struct WeaponList: Codable {
        public let id: WeaponType.WeaponId
        public let weapon: Brand?
        public let coopSpecialWeapon: Brand?

        public init(id: WeaponType.WeaponId, weapon: Result.Brand?, coopSpecialWeapon: Result.Brand?) {
            self.id = id
            self.weapon = weapon
            self.coopSpecialWeapon = coopSpecialWeapon
        }
    }

    // MARK: - Brand
    public struct Brand: Codable {
        public let id: WeaponType.WeaponId?
        public let thumbnail: String?
        public let image: WeaponType.Image
        public let name: String

        public init(id: WeaponType.WeaponId?, thumbnail: String?, image: WeaponType.Image, name: String) {
            self.id = id
            self.thumbnail = thumbnail
            self.image = image
            self.name = name
        }
    }

    // MARK: - Schedule
    public struct Schedule: Codable {
        public let stage: Stage
        public let weapons: [WeaponList]
        public let endTime, startTime: Int

        public init(stage: Result.Stage, weapons: [Result.WeaponList], endTime: Int, startTime: Int) {
            self.stage = stage
            self.weapons = weapons
            self.endTime = endTime
            self.startTime = startTime
        }
    }

    // MARK: - Stage
    public struct Stage: Codable {
        public let name: String
        public let image: StageType.Image

        public init(name: String, image: StageType.Image) {
            self.name = name
            self.image = image
        }
    }

    public enum StageType {
        public enum Image: String, Codable, CaseIterable {
            case shakeup = "/images/coop_stage/65c68c6f0641cc5654434b78a6f10b0ad32ccdee.png"
            case shakeship = "/images/coop_stage/e07d73b7d9f0c64e552b34a2e6c29b8564c63388.png"
            case shakehouse = "/images/coop_stage/6d68f5baa75f3a94e5e9bfb89b82e7377e3ecd2c.png"
            case shakelift = "/images/coop_stage/e9f7c7b35e6d46778cd3cbc0d89bd7e1bc3be493.png"
            case shakeride = "/images/coop_stage/50064ec6e97aac91e70df5fc2cfecf61ad8615fd.png"
        }
    }

    // MARK: - WaveDetail
    public struct WaveDetail: Codable {
        public let quotaNum, goldenIkuraPopNum: Int
        public let waterLevel: WaterLevel
        public let ikuraNum, goldenIkuraNum: Int
        public let eventType: EventType

        public init(quotaNum: Int, goldenIkuraPopNum: Int, waterLevel: Result.WaterLevel, ikuraNum: Int, goldenIkuraNum: Int, eventType: Result.EventType) {
            self.quotaNum = quotaNum
            self.goldenIkuraPopNum = goldenIkuraPopNum
            self.waterLevel = waterLevel
            self.ikuraNum = ikuraNum
            self.goldenIkuraNum = goldenIkuraNum
            self.eventType = eventType
        }
    }
}
