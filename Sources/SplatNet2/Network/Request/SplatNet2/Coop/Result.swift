//
//  Result.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

public class Result: RequestType {
    public typealias ResponseType = Result.Response

    public var baseURL = URL(unsafeString: "https://app.splatoon2.nintendo.net/api/")
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    public var headers: [String: String]?

    init(jobId: Int) {
        self.path = "coop_results/\(jobId)"
    }

    // MARK: - Result
    public struct Response: Codable {
        public let jobScore: Int
        public let playerType: PlayerType?
        public let grade: GradeType?
        //  swiftlint:disable:next discouraged_optional_collection
        public let otherResults: [PlayerResult]
        public let schedule: Schedule
        public let kumaPoint: Int?
        public let waveDetails: [WaveDetail]
        public let jobResult: JobResult
        public let jobId: Int?
        public let startTime: Int
        public let myResult: PlayerResult
        public let gradePointDelta: Int?
        public let jobRate, endTime: Int
        public let bossCounts: [String: BossCount]
        public let gradePoint, playTime: Int
        public let dangerRate: Double
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
        public let name: BossName
        public let key: BossKey
        
        public init(name: Result.BossName, key: Result.BossKey) {
            self.name = name
            self.key = key
        }
    }

    public struct EventType: Codable {
        public let name: EventName
        public let key: EventKey
        
        public init(name: Result.EventName, key: Result.EventKey) {
            self.name = name
            self.key = key
        }
        
    }

    public struct WaterLevel: Codable {
        public let name: WaterName
        public let key: WaterKey
    
        public init(name: Result.WaterName, key: Result.WaterKey) {
            self.name = name
            self.key = key
        }
    }

    public enum BossKey: String, Codable {
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

    public enum EventKey: String, Codable {
        case cohockCharge = "cohock-charge"
        case fog = "fog"
        case goldieSeeking = "goldie-seeking"
        case griller = "griller"
        case rush = "rush"
        case theMothership = "the-mothership"
        case waterLevels = "water-levels"
    }

    public enum WaterKey: String, Codable {
        case high
        case low
        case normal
    }

    public enum BossName: String, Codable {
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

    public enum EventName: String, Codable {
        case rush = "Rush"
        case cohockCharge = "Cohock Charge"
        case waterLevels = "-"
        case goldieSeeking = "Goldie Seeking"
        case theGriller = "The Griller"
        case theMothership = "The Mothership"
        case fog = "Fog"
    }

    public enum WaterName: String, Codable {
        case highTide = "High tide"
        case lowTide = "Low tide"
        case normal = "Normal"
    }

    // MARK: - Grade
    public struct GradeType: Codable {
        public let longName: GradeName?
        public let id: String
        public let shortName: GradeName?
        public let name: GradeName
        
        public init(longName: Result.GradeName?, id: String, shortName: Result.GradeName?, name: Result.GradeName) {
            self.longName = longName
            self.id = id
            self.shortName = shortName
            self.name = name
        }
    }

    public enum GradeName: String, Codable {
        case profreshional = "Profreshional"
        case overachiver = "Over achiver"
        case gogetter = "Go getter"
        case parttimer = "Part timer"
        case apparentice = "Apparentice"
        case intern = "Intern"
    }

    // MARK: - JobResult
    public struct JobResult: Codable {
        public let failureWave: Int?
        public let isClear: Bool
        public let failureReason: String?
        
        public init(failureWave: Int?, isClear: Bool, failureReason: String?) {
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
        public let bossKillCounts: [String: BossCount]
        public let special: SpecialType
        public let deadCount: Int
        public let name: String
        public let ikuraNum: Int
        public let playerType: PlayerType
        public let helpCount: Int
        public let weaponList: [WeaponList]
    }

    // MARK: - PlayerType
    public struct PlayerType: Codable {
        public let style: Style
        public let species: Species
    }

    public enum Species: String, Codable {
        case inklings
        case octlings
    }

    public enum Style: String, Codable {
        case girl
        case boy
    }

    // MARK: - Special
    public struct SpecialType: Codable {
        public let imageA: ImageA
        public let imageB: ImageB
        public let name: SpecialName
        public let id: String
        
        public init(imageA: Result.ImageA, imageB: Result.ImageB, name: Result.SpecialName, id: String) {
            self.imageA = imageA
            self.imageB = imageB
            self.name = name
            self.id = id
        }
    }

    public enum ImageA: String, Codable {
        case inkjet = "/images/special/18990f646c551ee77c5b283ec814e371f692a553.png"
        case splashdown = "/images/special/324d41e9582d84101152849bc8c96d6595c9b0ff.png"
        case splatBombLauncher = "/images/special/7af300fdd872feb27b3d8e68a969457fac8b3bb7.png"
        case stingRay = "/images/special/9871c82952ed0141be0310ace1942c9f5f66d655.png"
    }

    public enum ImageB: String, Codable {
        case inkjet = "/images/special/26e8117808ce17dadb0f23943359e5909fef4085.png"
        case splashdown = "/images/special/485b748720bbf809d8b28f9f4ee1a505cbcb339b.png"
        case splatBombLauncher = "/images/special/4eb81e00f5d707248879a7c7037d8475716a8045.png"
        case stingRay = "/images/special/9e89e1d67803c3021203182ecc7f38bc2c0f5400.png"
    }

    public enum SpecialName: String, Codable {
        case inkjet = "Inkjet"
        case splashdown = "Splashdown"
        case splatBombLauncher = "Splat-Bomb Launcher"
        case stingRay = "Sting Ray"
    }

    // MARK: - WeaponListElement
    public struct WeaponList: Codable {
        public let id: String
        public let weapon: Brand?
        public let coopSpecialWeapon: Brand?
        
        public init(id: String, weapon: Result.Brand?, coopSpecialWeapon: Result.Brand?) {
            self.id = id
            self.weapon = weapon
            self.coopSpecialWeapon = coopSpecialWeapon
        }
    }

    // MARK: - Brand
    public struct Brand: Codable {
        public let id, thumbnail: String?
        public let image, name: String
        
        public init(id: String?, thumbnail: String?, image: String, name: String) {
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
        public let name: StageName
        public let image: String
        
        public init(name: Result.StageName, image: String) {
            self.name = name
            self.image = image
        }
    }

    public enum StageName: String, Codable {
        case shakeship = "Marooner's Bay"
        case shakeride = "Ruins of Ark Polaris"
        case shakelift = "Salmonid Smokeyard"
        case shakeup = "Spawning Grounds"
        case shakehouse = "Lost Outpost"
    }

    // MARK: - WaveDetail
    public struct WaveDetail: Codable {
        public let quotaNum, goldenIkuraPopNum: Int
        public let waterLevel: WaterLevel
        public let ikuraNum, goldenIkuraNum: Int
        public let eventType: EventType
        
        public init(quotaNum: Int, goldenIkuraPopNum: Int, waterLevel: Result.WaterLevel, ikuraNum: Int, goldenIkuraNum: Int, eventType: Result.EventType {
            self.quotaNum = quotaNum
            self.goldenIkuraPopNum = goldenIkuraPopNum
            self.waterLevel = waterLevel
            self.ikuraNum = ikuraNum
            self.goldenIkuraNum = goldenIkuraNum
            self.eventType = eventType
        }
    }
}
