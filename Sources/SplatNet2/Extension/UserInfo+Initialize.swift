//
//  File.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Common
import Foundation

extension UserInfo {
    convenience init(sessionToken: String, response: IksmSession.Response, nickname: String, membership: Bool, thumbnailURL: String) {
        self.init(nsaid: response.nsaid, nickname: nickname)
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
