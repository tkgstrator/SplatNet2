//  swiftlint:disable:this file_name
//
//  Publisher.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Foundation

extension SplatNet2 {
    /// リクエストを実行(IksmSessionを取得)
    func generate(accessToken: String) -> AnyPublisher<IksmSession.Response, SP2Error> {
        Future { [self] promise in
            session.request(IksmSession(accessToken: accessToken))
                .validate()
                .validate(contentType: ["text/html"])
                .responseString { response in
                    switch response.result {
                    case .success(let value):
                        do {
                            guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else {
                                throw SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: 404), failure: nil)
                            }
                            guard let header = response.response?.allHeaderFields as? [String: String], let url = response.response?.url else {
                                throw SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: 404), failure: nil)
                            }
                            guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: header, for: url).first?.value else {
                                throw SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: 404), failure: nil)
                            }
                            promise(.success(IksmSession.Response(iksmSession: iksmSession, nsaid: nsaid)))
                        } catch {
                            promise(.failure(SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: 404), failure: nil)))
                        }
                    case .failure:
                        promise(.failure(SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: 404), failure: nil)))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    /// リクエストを実行(エラー9427がでたらX-ProductVersionを自動でアップデート)
    internal func authorize<T: RequestType>(_ request: T) -> AnyPublisher<T.ResponseType, SP2Error> {
        session
            .request(request, interceptor: self)
            .cURLDescription { request in
                DDLogInfo(request)
            }
            .validationWithSP2Error(decoder: decoder)
            .publishDecodable(type: T.ResponseType.self, decoder: decoder)
            .value()
            .mapError({ error -> SP2Error in
                DDLogError(error)
                guard let sp2Error = error.asSP2Error else {
                    return SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: error.responseCode ?? 999), failure: nil)
                }
                return sp2Error
            })
            .eraseToAnyPublisher()
    }
}
