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

extension SplatNet2 {
    static func generate(accessToken: String) -> AnyPublisher<IksmSession.Response, AFError> {
        Future { promise in
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
                                guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else { throw APIError.OAuth(.response, nil) }
                                guard let iksmSession = HTTPCookie.cookies(
                                    withResponseHeaderFields: (response.response?.allHeaderFields as! [String: String]),
                                    for: (response.response?.url!)!).first?.value else { throw APIError.OAuth(.response, nil) }
                                promise(.success(IksmSession.Response(iksmSession: iksmSession, nsaid: nsaid)))
                            } catch let error as APIError {
//                                promise(.failure(error))
                            } catch let error as AFError {
                                promise(.failure(error))
                            } catch {
                            }
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    /// リクエストを実行
    public static func publish<T: RequestType>(_ request: T) -> DataResponsePublisher<T.ResponseType> {
        session.request(request)
            .validate(statusCode: 200...200)
            .validate(contentType: ["application/json"])
            .cURLDescription { request in
                #if DEBUG
                print(request)
                #endif
            }
            .publishDecodable(type: T.ResponseType.self, decoder: decoder)
    }
}

public extension String {
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }

    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return []
        }
        return group.map { group -> String in
            (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
