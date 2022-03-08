//
//  StatsResult.swift
//  SalmonStats
//
//  Created by tkgstrator on 2021/04/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CodableDictionary
import Common
import Foundation
import SplatNet2

public class StatsResult: RequestType {
    public typealias ResponseType = StatsResult.Response

    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String: String]?

    init(resultId: Int) {
        self.path = "results/\(resultId)"
    }

    // MARK: - Result
    public struct Response: Codable {
        public let id: Int
        public let scheduleId, startAt: String
        public let members: [String]
        public let bossAppearances: CodableDictionary<BossId, Int>
        public let uploaderUserId, clearWaves: Int
        public let failReasonId: Int?
        public let dangerRate, createdAt, updatedAt: String
        public let goldenEggDelivered, powerEggCollected, bossAppearanceCount, bossEliminationCount: Int
        public let isEligibleForNoNightRecord: Bool
        //  swiftlint:disable:next discouraged_optional_collection
        public let memberAccounts: [MemberAccount]?
        public let schedule: Schedule?
        public let playerResults: [PlayerResult]
        public let waves: [Wave]
    }

    // MARK: - MemberAccount
    public struct MemberAccount: Codable {
        public let playerId, name: String
        public let id: Int?
        public let twitterAvatar: String?
        public let updatedAt: String?
        public let userId, isPrimary: Int?
        //  swiftlint:disable:next discouraged_optional_boolean
        public let isCustomName, isRegistered: Bool?
    }

    // MARK: - PlayerResult
    public struct PlayerResult: Codable {
        public let playerId: String
        public let goldenEggs, powerEggs, rescue, death: Int
        public let specialId: SpecialId
        public let bossEliminationCount: Int
        public let gradePoint: Int?
        public let bossEliminations: BossEliminations
        public let specialUses: [Special]
        public let weapons: [Weapon]
    }

    // MARK: - BossEliminations
    public struct BossEliminations: Codable {
        public let counts: CodableDictionary<BossId, Int>
    }

    // MARK: - SpecialType
    public enum SpecialId: Int, Codable, CaseIterable {
        case splatBombLauncher  = 2
        case stingRay           = 7
        case inkjet             = 8
        case splashdown         = 9
    }

    // MARK: - Special
    public struct Special: Codable {
        public let count: Int
    }

    // MARK: - Weapon
    public struct Weapon: Codable {
        public let weaponId: Int
    }

    // MARK: - Schedule
    public struct Schedule: Codable {
        public let scheduleId, endAt: String
        public let weapons: [Int]
        public let stageId: StageId
        public let rareWeaponId: Int?
    }

    public enum StageId: Int, Codable, CaseIterable {
        case shakeup = 1
        case shakeship = 2
        case shakehouse = 3
        case shakelift = 4
        case shakeride = 5
    }

    // MARK: - Wave
    public struct Wave: Codable {
        public let wave, eventId, waterId, goldenEggQuota: Int
        public let goldenEggAppearances, goldenEggDelivered, powerEggCollected: Int
    }
}
