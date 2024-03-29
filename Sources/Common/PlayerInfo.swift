//
//  PlayerInfo.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Foundation

// MARK: - PlayerInfo
public struct RankedInfo: Codable {
    let player: Player
    let startTime: Int
    let loseCount: Int
    let totalPaintPointOcta: Int
//    let fesResults: FesResults
    let recentWinCount: Int
    let winCount: Int
    let recentLoseCount: Int
    let stageStats: [String: StageStat]
    let weaponStats: [String: WeaponStat]
    let uniqueID: String
    let leagueStats: LeagueStats
    let recentDisconnectCount: Int
    let updateTime: Int
}

// MARK: - Player
public struct Player: Codable {
    let udemaeRainmaker: Udemae
    let playerRank: Int
    let maxLeaguePointPair: Double
    let principalID: String
    let playerType: PlayerType
    let clothes: Clothes
    let head: Clothes
    let starRank: Int
    let udemaeZones: Udemae
    let weapon: Weapon
    let nickname: String
    let maxLeaguePointTeam: Double
    let shoesSkills: Skills
    let udemaeClam: Udemae
    let shoes: Clothes
    let headSkills: Skills
    let udemaeTower: Udemae
    let clothesSkills: Skills
}

// MARK: - LeagueStats
public struct LeagueStats: Codable {
    let pair: Pair
    let team: Pair
}

// MARK: - Pair
public struct Pair: Codable {
    let noMedalCount: Int
    let goldCount: Int
    let bronzeCount: Int
    let silverCount: Int
}

// MARK: - Clothes
public struct Clothes: Codable {
    let brand: Brand
    let id: String
    let thumbnail: String
    let rarity: Int
    let image: String
    let name: String
    let kind: String
}

// MARK: - Brand
public class Brand: Codable {
    let frequentSkill: Brand?
    let id: String
    let image: String
    let name: String
}

// MARK: - Skills
public struct Skills: Codable {
    let main: Brand
    let subs: [Brand?]
}

// MARK: - PlayerType
public struct PlayerType: Codable {
    let style: String
    let species: String
}

// MARK: - Udemae
public struct Udemae: Codable {
    let sPlusNumber: Int?
    let name: String
    let isNumberReached: Bool
    let number: Int
    let isX: Bool
}

// MARK: - Weapon
public struct Weapon: Codable {
    let sub: Special
    let special: Special
    let image: String
    let name: String
    let id: String
    let thumbnail: String
}

// MARK: - Special
public struct Special: Codable {
    let name: String
    let imageA: String
    let id: String
    let imageB: String
}

// MARK: - StageStat
public struct StageStat: Codable {
    let asariLose: Int
    let yaguraLose: Int
    let hokoWin: Int
    let areaLose: Int
    let asariWin: Int
    let lastPlayTime: Int
    let yaguraWin: Int
    let stage: Brand
    let hokoLose: Int
    let areaWin: Int
}

// MARK: - WeaponStat
public struct WeaponStat: Codable {
    let weapon: Weapon
    let totalPaintPoint: Int
    let loseCount: Int
    let winMeter: Double
    let winCount: Int
    let maxWinMeter: Double
    let lastUseTime: Int
}
