//  swiftlint:disable:this file_name
//
//  Publisher.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Combine
import Foundation
import SwiftyJSON

extension SplatNet2 {
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
                                throw SP2Error.dataDecodingFailed
                            }
                            guard let header = response.response?.allHeaderFields as? [String: String], let url = response.response?.url else {
                                throw SP2Error.dataDecodingFailed
                            }
                            guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: header, for: url).first?.value else {
                                throw SP2Error.dataDecodingFailed
                            }
                            promise(.success(IksmSession.Response(iksmSession: iksmSession, nsaid: nsaid)))
                        } catch {
                            promise(.failure(SP2Error.dataDecodingFailed))
                        }
                    case .failure:
                        promise(.failure(SP2Error.dataDecodingFailed))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    // リクエストを実行
    public func publish<T: RequestType>(_ request: T) -> AnyPublisher<T.ResponseType, SP2Error> {
        Future { [self] promise in
            session.request(request, interceptor: self)
            .validate()
            .validate(contentType: ["application/json", "text/javascript"])
            .publishDecodable(type: T.ResponseType.self, queue: DispatchQueue(label: "SplatNet2"), preprocessor: self, decoder: decoder)
            .value()
            .mapError({ error -> SP2Error in
                switch error {
//                case .requestRetryFailed(retryError: _, originalError: let error):

                case .responseValidationFailed(reason: let reason):
                    switch reason {
                    case .unacceptableStatusCode(code: let code):
                        if let statusCode = SP2Error.HTTPError(rawValue: code) {
                            return SP2Error.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode), failure: nil)
                        } else {
                            return SP2Error.responseSerializationFailed
                        }
                    default:
                        return SP2Error.responseValidationFailed(reason: .customValidationFailed, failure: nil)
                    }
                case .responseSerializationFailed(reason: let reason):
                    switch reason {
                    case .customSerializationFailed(error: let error as SP2Error):
                        return error
                    default:
                        return SP2Error.responseValidationFailed(reason: .customValidationFailed, failure: nil)
                    }
                default:
                    return SP2Error.responseSerializationFailed
                }
            })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }, receiveValue: { response in
                promise(.success(response))
            })
            .store(in: &task)
        }
        .eraseToAnyPublisher()
    }

    func execute<T: RequestType>(_ request: T) {
        session.request(request)
            .validate()
            .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                }
            })
            .resume()
    }
}
