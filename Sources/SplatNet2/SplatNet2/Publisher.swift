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
                .validate(statusCode: 200 ... 200)
                .validate(contentType: ["text/html"])
                .cURLDescription { request in
#if DEBUG
                    print(request)
#endif
                }
                .responseString { response in
                    switch response.result {
                        case .success(let value):
                            do {
                                guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else {
                                    throw SP2Error.OAuth(.response, nil)
                                }
                                guard let header = response.response?.allHeaderFields as? [String: String], let url = response.response?.url else {
                                    throw SP2Error.OAuth(.response, nil)
                                }
                                guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: header, for: url).first?.value else {
                                    throw SP2Error.OAuth(.response, nil)
                                }
                                promise(.success(IksmSession.Response(iksmSession: iksmSession, nsaid: nsaid)))
                            } catch let error as SP2Error {
                                promise(.failure(error))
                            } catch {
                                promise(.failure(SP2Error.Session(.unavailable, nil, nil)))
                            }
                        case .failure(let error):
                            promise(.failure(SP2Error.Session(.unavailable, nil, error)))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    // リクエストを実行
    //  swiftlint:disable cyclomatic_complexity function_body_length
    public func publish<T: RequestType>(_ request: T) -> AnyPublisher<T.ResponseType, SP2Error> {
        Future { [self] promise in
            session.request(request, interceptor: self)
                .validate()
                .validate(contentType: ["application/json", "text/javascript"])
                .cURLDescription { request in
#if DEBUG
                    print(request)
#endif
                }
                .responseJSON(completionHandler: { response in
                    switch response.result {
                        case .success(let value):
                            // データがない場合
                            guard let data = response.data else {
                                promise(.failure(SP2Error.Data(.response, nil)))
                                return
                            }
                            #if DEBUG
                            print(try? JSON(data: data))
                            #endif
                            do {
                                let response = try decoder.decode(T.ResponseType.self, from: data)
                                promise(.success(response))
                            } catch {
                                do {
                                    let response = try decoder.decode(SP2Error.Failure.self, from: data)
                                    // ステータスコードが200なのにデコードできないことはない
                                    guard let statusCode = response.status else {
                                        promise(.failure(SP2Error.Data(.unknown, error)))
                                        return
                                    }
                                    // SplatoonToken/SplatoonAccessTokenでのエラー
                                    switch statusCode {
                                        case 400:
                                            promise(.failure(SP2Error.Session(.badrequest, response, nil)))
                                        case 403:
                                            promise(.failure(SP2Error.Session(.forbidden, response, nil)))
                                        case 404:
                                            promise(.failure(SP2Error.Session(.notfound, response, nil)))
                                        case 406:
                                            promise(.failure(SP2Error.Session(.unacceptable, response, nil)))
                                        case 427:
                                            promise(.failure(SP2Error.Session(.upgrade, response, nil)))
                                        default:
                                            promise(.failure(SP2Error.Session(.unavailable, response, nil)))
                                    }
                                } catch {
                                    promise(.failure(SP2Error.Data(.unknown, error)))
                                }
                            }
                        case .failure(let error):
                            guard let statusCode = response.response?.statusCode, let status = SP2Error.Http(rawValue: statusCode) else {
                                promise(.failure(SP2Error.Session(.unavailable, nil, error)))
                                return
                            }
                            promise(.failure(SP2Error.Session(status, nil, error)))
                    }
                })
        }
        .eraseToAnyPublisher()
    }
    //  swiftlint:enable cyclomatic_complexity function_body_length

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
