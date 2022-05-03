//
//  UserInfo.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public struct UserInfo: Codable {
    /// ニックネーム
    public var nickname: String
    /// Nintendo Switch Online加入済みかどうか
    public var membership: Bool
    /// フレンドコード
    public var friendCode: String
    /// アイコンURL
    //  swiftlint:disable:next force_unwrapping
    public var thumbnailURL: URL = Bundle.module.url(forResource: "icon", withExtension: "png")!
    /// 認証用のパラメータなど
    public var credential: OAuthCredential
    /// バイト情報
    public var resultCoop: CoopInfo = CoopInfo()
    
    /// ダミーアカウント
    public init() {
        self.nickname = "Undefined"
        self.membership = false
        self.friendCode = "XXXX-XXXX-XXXX"
        self.credential = OAuthCredential(nsaid: "xxxxxxxxxxxxxxxx", iksmSession: "", sessionToken: "", splatoonToken: "")
    }
    
    /// アカウント
    public init(nsaid: String, membership: Bool, friendCode: String, sessionToken: String, splatoonToken: String, iksmSession: String, thumbnailURL: URL, nickname: String) {
        self.credential = OAuthCredential(nsaid: nsaid, iksmSession: iksmSession, sessionToken: sessionToken, splatoonToken: splatoonToken)
        self.thumbnailURL = thumbnailURL
        self.nickname = nickname
        self.membership = membership
        self.friendCode = friendCode
    }
}

extension UserInfo: Identifiable {
    public var id: String { credential.nsaid }
}

extension UserInfo: Equatable, Hashable {
    public static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        lhs.id == rhs.id
    }

    public static func != (lhs: UserInfo, rhs: UserInfo) -> Bool {
        lhs.id != rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
