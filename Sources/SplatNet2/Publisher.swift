//
//  Publisher.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//

import Foundation
import Combine
import Alamofire
import SwiftyJSON

extension SplatNet2 {
    func generate(accessToken: String) -> AnyPublisher<IksmSession.Response, SP2Error> {
        return Future { [self] promise in
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
                            print(JSON(value))
                            do {
                                guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else { throw SP2Error.OAuth(.response, nil) }
                                guard let iksmSession = HTTPCookie.cookies(
                                    withResponseHeaderFields: (response.response?.allHeaderFields as! [String: String]),
                                    for: (response.response?.url!)!).first?.value else { throw SP2Error.OAuth(.response, nil) }
                                promise(.success(IksmSession.Response(iksmSession: iksmSession, nsaid: nsaid)))
                            } catch (let error as SP2Error) {
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
    
    /// リクエストを実行
    public func publish<T: RequestType>(_ request: T) -> AnyPublisher<T.ResponseType, SP2Error> {
        Future { [self] promise in
            session.request(request)
                .validate(statusCode: 200 ... 200)
                .validate(contentType: ["application/json", "text/javascript"])
                .cURLDescription { request in
#if DEBUG
                    print(request)
#endif
                }
                .responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success(let value):
                        print(JSON(value))
                        // データがない場合
                        guard let data = response.data else {
                            promise(.failure(SP2Error.Data(.response, nil)))
                            return
                        }
                        // エンコード失敗
                        guard let response = try? decoder.decode(T.ResponseType.self, from: data) else {
                            guard let response = try? decoder.decode(SP2Error.Failure.self, from: data) else {
                                promise(.failure(SP2Error.Data(.undecodable, nil)))
                                return
                            }
                            /// ステータスコードが200なのにデコードできないことはない
                            guard let statusCode = response.status else {
                                promise(.failure(SP2Error.Data(.unknown, nil)))
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
                            return
                        }
                        promise(.success(response))
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
