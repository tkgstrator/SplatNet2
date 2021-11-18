//
//  Summary.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//

import Foundation
import Alamofire

public class Results: RequestType {
    public var baseURL: URL = URL(string: "https://app.splatoon2.nintendo.net/api/")!
    public var method: HTTPMethod = .get
    public var path: String = "coop_results"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Results.Response
    
    init(iksmSession: String) {
        self.headers = ["cookie": "iksm_session=\(iksmSession)"]
    }
    
    // MARK: - CoopResults
    public struct Response: Codable {
        let summary: Summary
        let results: [Result.Response]
        let rewardGear: RewardGear

        // MARK: - RewardGear
        struct RewardGear: Codable {
            let kind, thumbnail, image, id: String
            let name: String
            let brand: Result.Brand
            let rarity: Int
        }

        // MARK: - Summary
        struct Summary: Codable {
            let stats: [Stat]
            let card: Card
        }

        // MARK: - Card
        struct Card: Codable {
            let ikuraTotal, kumaPointTotal, kumaPoint, goldenIkuraTotal: Int
            let jobNum, helpTotal: Int
        }

        // MARK: - Stat
        struct Stat: Codable {
            let grade: Result.GradeType
            let myGoldenIkuraTotal, helpTotal, deadTotal, clearNum: Int
            let teamGoldenIkuraTotal: Int
            let failureCounts: [Int]
            let gradePoint: Int
            let schedule: Schedule
            let endTime, startTime, myIkuraTotal, teamIkuraTotal: Int
            let kumaPointTotal, jobNum: Int
        }
    }
}
