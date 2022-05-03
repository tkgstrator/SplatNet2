//
//  OAuthCredential.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

public struct OAuthCredential: AuthenticationCredential, Codable {
    public var iksmSession: String
    public let sessionToken: String
    public var splatoonToken: String
    public let nsaid: String
    let expiration: Date

    #if DEBUG
    public var requiresRefresh: Bool { Date(timeIntervalSinceNow: 60 * 60 * 23) > expiration }
    #else
    public var requiresRefresh: Bool { Date(timeIntervalSinceNow: 60 * 60 * 23) > expiration }
    #endif

    public init(nsaid: String, iksmSession: String, sessionToken: String, splatoonToken: String) {
        self.iksmSession = iksmSession
        self.sessionToken = sessionToken
        self.splatoonToken = splatoonToken
        self.nsaid = nsaid
        self.expiration = Date(timeIntervalSinceNow: 60 * 60 * 24)
    }
}
