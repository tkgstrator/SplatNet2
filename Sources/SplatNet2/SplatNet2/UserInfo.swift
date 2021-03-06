//
//  UserInfo.swift
//  
//
//  Created by devonly on 2021/07/03.
//

import Foundation

public struct UserInfo: Codable, Hashable, Identifiable {
    public static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        lhs.nsaid == rhs.nsaid
    }
    
    public var id: UUID { UUID() }
    public var iksmSession: String = ""
    public var nsaid: String = ""
    public var nickname: String = ""
    public var membership: Bool = false
    public var imageUri: URL = Bundle.module.url(forResource: "icon", withExtension: "png")!
    public var sessionToken: String = ""
    public var coop: CoopInfo = CoopInfo()

    init() {}
    init(sessionToken: String, response: IksmSession.Response, splatoonToken: SplatoonToken.Response) {
        self.sessionToken = sessionToken
        self.iksmSession = response.iksmSession
        self.nsaid = response.nsaid
        self.nickname = splatoonToken.result.user.name
        self.membership = splatoonToken.result.user.membership.active
        self.imageUri = URL(string: splatoonToken.result.user.imageUri)!
        self.coop = CoopInfo()
    }

    public struct CoopInfo: Codable, Hashable {
        public var jobNum: Int = 0
        public var goldenIkuraTotal: Int = 0
        public var ikuraTotal: Int = 0
        public var kumaPoint: Int = 0
        public var kumaPointTotal: Int = 0
        
        init() {}
        init(from response: SummaryCoop.Response) {
            self.jobNum = response.summary.card.jobNum
            self.goldenIkuraTotal = response.summary.card.goldenIkuraTotal
            self.ikuraTotal = response.summary.card.ikuraTotal
            self.kumaPoint = response.summary.card.kumaPoint
            self.kumaPointTotal = response.summary.card.kumaPointTotal
        }
    }
}
