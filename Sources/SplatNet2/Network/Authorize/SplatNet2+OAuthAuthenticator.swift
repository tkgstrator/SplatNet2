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
import Foundation

extension SplatNet2: Authenticator {
    public func apply(
        _ credential: OAuthCredential,
        to urlRequest: inout URLRequest
    ) {
        urlRequest.headers.add(HTTPHeader(name: "cookie", value: "iksm_session=\(credential.iksmSession)"))
    }

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
                        DDLogError(error)
                        completion(.failure(error))
                        return
                }
            }, receiveValue: { [self] response in
                // 怪しい部分なので検証が必要
                accounts = accounts.filter({ $0.credential.nsaid != response.credential.nsaid }) + [response]
                completion(.success(response.credential))
                return
            })
            .store(in: &task)
    }

    public func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool {
        response.statusCode == 403
    }

    public func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: OAuthCredential
    ) -> Bool {
        false
    }
}
