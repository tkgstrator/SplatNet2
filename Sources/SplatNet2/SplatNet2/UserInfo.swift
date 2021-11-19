//
//  UserInfo.swift
//  
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.

import Foundation

public class UserInfo: Codable {
    /// イカスミトークン
    public var iksmSession: String
    /// プレイヤーID
    public var nsaid: String
    /// ニックネーム
    public var nickname: String
    /// Nintendo Switch Online加入済みかどうか
    public var membership: Bool
    /// アイコンURL
    public var imageUri: URL
    /// セッショントークン
    public var sessionToken: String
    /// バイト情報
    public var coop: CoopInfo

    public init(nsaid: String, nickname: String) {
        self.sessionToken = ""
        self.iksmSession = ""
        self.nsaid = nsaid
        self.nickname = nickname
        self.membership = false
        self.imageUri = Bundle.module.url(forResource: "icon", withExtension: "png")!
        self.coop = CoopInfo()
    }

    init(sessionToken: String, response: IksmSession.Response, nickname: String, membership: Bool, imageUri: String) {
        self.sessionToken = sessionToken
        self.iksmSession = response.iksmSession
        self.nsaid = response.nsaid
        self.nickname = nickname
        self.membership = membership
        self.imageUri = URL(unsafeString: imageUri)
        self.coop = CoopInfo()
    }

    public class CoopInfo: Codable {
        /// バイト回数
        public var jobNum: Int = 0
        /// 総金イクラ数
        public var goldenIkuraTotal: Int = 0
        /// 総赤イクラ数
        public var ikuraTotal: Int = 0
        /// クマサンポイント
        public var kumaPoint: Int = 0
        /// 総クマポイント
        public var kumaPointTotal: Int = 0

        init() {}

        init(from response: Results.Response) {
            self.jobNum = response.summary.card.jobNum
            self.goldenIkuraTotal = response.summary.card.goldenIkuraTotal
            self.ikuraTotal = response.summary.card.ikuraTotal
            self.kumaPoint = response.summary.card.kumaPoint
            self.kumaPointTotal = response.summary.card.kumaPointTotal
        }
    }
}

open class UserAccess: Codable {
    /// X-Product Version
    open var version: String = "1.13.2"
    /// Service Name
    open var service: String = "Salmonia3/@tkgling"
    /// Release Date(ISO8601 format)
    open var releaseDate: String = "2021-10-01T:00:00:00Z"
    /// SplatNet2 Account
    public var accounts: [UserInfo]

    internal init(accounts: [UserInfo]) {
        self.accounts = accounts
    }

    internal init(version: String, accounts: [UserInfo]) {
        self.version = version
        self.accounts = accounts
    }

    internal init(version: String, releaseDate: String, accounts: [UserInfo]) {
        self.version = version
        self.releaseDate = releaseDate
        self.accounts = accounts
    }
}

extension UserInfo: Identifiable {
    public var id: String { nsaid }
}
