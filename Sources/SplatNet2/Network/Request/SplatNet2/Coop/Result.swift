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

//  swiftlint:disable type_body_length
public class Result: RequestType {
    public typealias ResponseType = Result.Response

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
        public let bossCounts: CodableDictionary<BossType, BossCount>
        public let gradePoint: Int?
        public let dangerRate: Double

        public init(
            jobScore: Int?,
            playerType: Result.PlayerType?,
            grade: Result.GradeType?,
            //  swiftlint:disable:next discouraged_optional_collection
            otherResults: [Result.PlayerResult]?,
            schedule: Result.Schedule,
            kumaPoint: Int?,
            waveDetails: [Result.WaveDetail],
            jobResult: Result.JobResult,
            jobId: Int?,
            myResult: Result.PlayerResult,
            gradePointDelta: Int?,
            jobRate: Int?,
            startTime: Int,
            playTime: Int,
            endTime: Int,
            bossCounts: CodableDictionary<BossType, BossCount>,
            gradePoint: Int?,
            dangerRate: Double
        ) {
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

        public init(name: String, key: BossKey) {
            self.name = name
            self.key = key
        }
    }

    // MARK: - EventType
    public struct EventType: Codable {
        public let name: String
        public let key: EventKey

        public init(name: String, key: EventKey) {
            self.name = name
            self.key = key
        }
    }

    // MARK: - WaterLevel
    public struct WaterLevel: Codable {
        public let name: String
        public let key: WaterKey

        public init(name: String, key: WaterKey) {
            self.name = name
            self.key = key
        }
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
        public let bossKillCounts: CodableDictionary<BossType, BossCount>
        public let special: SpecialType
        public let deadCount: Int
        public let name: String?
        public let ikuraNum: Int
        public let playerType: PlayerType?
        public let helpCount: Int
        public let weaponList: [WeaponList]

        public init(
            pid: String,
            specialCounts: [Int],
            goldenIkuraNum: Int,
            bossKillCounts: CodableDictionary<BossType, BossCount>,
            special: Result.SpecialType,
            deadCount: Int,
            name: String?,
            ikuraNum: Int,
            playerType: Result.PlayerType?,
            helpCount: Int,
            weaponList: [Result.WeaponList]
        ) {
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

    // MARK: - Special
    public struct SpecialType: Codable {
        public let imageA: ImageA
        public let imageB: ImageB
        public let name: String
        public let id: SpecialId

        public init(imageA: ImageA, imageB: ImageB, name: String, id: SpecialId) {
            self.imageA = imageA
            self.imageB = imageB
            self.name = name
            self.id = id
        }
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

    // MARK: - WaveDetail
    public struct WaveDetail: Codable {
        public let quotaNum, goldenIkuraPopNum: Int
        public let waterLevel: WaterLevel
        public let ikuraNum, goldenIkuraNum: Int
        public let eventType: EventType

        public init(
            quotaNum: Int,
            goldenIkuraPopNum: Int,
            waterLevel: Result.WaterLevel,
            ikuraNum: Int,
            goldenIkuraNum: Int,
            eventType: Result.EventType
        ) {
            self.quotaNum = quotaNum
            self.goldenIkuraPopNum = goldenIkuraPopNum
            self.waterLevel = waterLevel
            self.ikuraNum = ikuraNum
            self.goldenIkuraNum = goldenIkuraNum
            self.eventType = eventType
        }
    }
}
//  swiftlint:enable type_body_length
