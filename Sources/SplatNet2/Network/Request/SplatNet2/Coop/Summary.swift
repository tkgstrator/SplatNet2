//
//  Summary.swift
//  SplatNet2
//
//  Created by devonly on 2021/07/13.
//

import Foundation
import Alamofire

public class SummaryCoop: RequestType {
    public var baseURL: URL = URL(string: "https://app.splatoon2.nintendo.net/api/")!
    public var method: HTTPMethod = .get
    public var path: String = "coop_results"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = SummaryCoop.Response
    
    init(iksmSession: String?) {
        self.headers = ["cookie": "iksm_session=\(iksmSession ?? "")"]
    }
    
    public struct Response : Codable {
//        var results: [ResultCoop]
//        var rewardGear
        public var summary: Summary
        
        public struct Summary: Codable {
            public var card: SummaryCard
            public var stats: [SummaryStat]
            
            public struct SummaryCard: Codable {
                public var goldenIkuraTotal: Int
                public var helpTotal: Int
                public var ikuraTotal: Int
                public var jobNum: Int
                public var kumaPoint: Int
                public var kumaPointTotal: Int
            }
            
            public struct SummaryStat: Codable {
                public var clearNum: Int
                public var deadTotal: Int
                public var endTime: Int
                public var failureCounts: [Int]
//              public   var grade
                public var gradePoint: Int
                public var helpTotal: Int
                public var jobNum: Int
                public var kumaPointTotal: Int
                public var myGoldenIkuraTotal: Int
                public var myIkuraTotal: Int
                public var startTime: Int
                public var teamGoldenIkuraTotal: Int
                public var teamIkuraTotal: Int
            }
        }
    }
}
