//
//  OAuthAuthenticator.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation

extension SplatNet2: Authenticator {
    // Credentialをリクエストに適用
    public func apply(
        _ credential: OAuthCredential,
        to urlRequest: inout URLRequest
    ) {
        // IksmSessionの値をヘッダーに追記
        urlRequest.headers.add(HTTPHeader(name: "cookie", value: "iksm_session=\(credential.iksmSession)"))
    }

    // リフレッシュが必要
    public func refresh(
        _ credential: OAuthCredential,
        for session: Session,
        completion: @escaping (Swift.Result<OAuthCredential, Error>) -> Void
    ) {
        getCookie(sessionToken: credential.sessionToken)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { [self] response in
                self.account = response
                self.delegate?.didFinishSplatNet2SignIn(account: response)
                completion(.success(response.credential))
                return
            })
            .store(in: &task)
    }

#warning("理解できてないので要修正")
    public func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool {
        response.statusCode == 403
    }

#warning("理解できてないので要修正")
    public func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: OAuthCredential
    ) -> Bool {
        false
    }
}
