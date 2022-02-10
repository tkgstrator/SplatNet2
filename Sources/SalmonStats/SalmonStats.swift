//
//  SalmonStats.swift
//  SalmonStats
//
//  Created by tkgstrator on 2021/04/10.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//  

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation
import KeychainAccess
import SplatNet2

public class SalmonStats: SplatNet2 {
    /// 認証用のAPIToken
    public internal(set) var apiToken: String? {
        get {
            keychain.getAPIToken()
        }
        set {
            keychain.setAPIToken(apiToken: newValue)
        }
    }

    /// APITokenをセット
    override public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        /// 親クラスの処理を実行
        super.adapt(urlRequest, for: session, completion: completion)
        /// SalmonStats用の処理を実行
        var urlRequest: URLRequest = urlRequest
        guard let apiToken = apiToken else {
            completion(.failure(SP2Error.credentialFailed))
            return
        }
        urlRequest.headers.update(.authorization(bearerToken: apiToken))
        return
    }
}

public extension RequestType {
    var baseURL: URL {
        URL(unsafeString: "https://salmon-stats-api.yuki.games/api/")
    }
}
