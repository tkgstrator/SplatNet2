//
//  UserInfo+Initialize.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Common
import Foundation

extension UserInfo {
    init(sessionToken: String, response: IksmSession.Response, user: SplatoonToken.Response) {
        self.init(
            nsaid: user.result.user.nsaId,
            membership: user.result.user.links.nintendoAccount.membership.active,
            friendCode: user.result.user.links.friendCode.id,
            sessionToken: sessionToken,
            splatoonToken: user.result.webApiServerCredential.accessToken,
            iksmSession: response.iksmSession,
            thumbnailURL: URL(unsafeString: user.result.user.imageUri),
            nickname: user.result.user.name
        )
    }
}
