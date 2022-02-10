//
//  UserInfo.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public class UserInfo: Codable {
    /// ニックネーム
    public var nickname: String
    /// Nintendo Switch Online加入済みかどうか
    public var membership: Bool
    /// アイコンURL
    //  swiftlint:disable:next force_unwrapping
    public var thumbnailURL: URL = Bundle.module.url(forResource: "icon", withExtension: "png")!
    /// 認証用のパラメータなど
    public var credential: OAuthCredential
    /// バイト情報
    public var coop = CoopInfo()

    public init(nsaid: String, nickname: String) {
        self.credential = OAuthCredential(
            iksmSession: "",
            sessionToken: "",
            nsaid: nsaid,
            expiration: Date(timeIntervalSinceNow: 0)
        )
        self.nickname = nickname
        self.membership = false
    }

    init(sessionToken: String, response: IksmSession.Response, nickname: String, membership: Bool, thumbnailURL: String) {
        self.credential = OAuthCredential(
            iksmSession: response.iksmSession,
            sessionToken: sessionToken,
            nsaid: response.nsaid,
            expiration: Date(timeIntervalSinceNow: 60 * 60 * 24)
        )
        self.nickname = nickname
        self.membership = membership
        self.thumbnailURL = URL(unsafeString: thumbnailURL)
    }
}

extension UserInfo: Identifiable {
    public var id: String { credential.nsaid }
}

extension UserInfo: Equatable, Hashable {
    public static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
