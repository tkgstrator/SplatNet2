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
    func generate(accessToken: String) -> AnyPublisher<IksmSession.Response, AFError> {
        Future { [self] promise in
            session.request(IksmSession(accessToken: accessToken))
                .validate()
                .validate(contentType: ["text/html"])
                .responseString { response in
                    switch response.result {
                    case .success(let value):
                        do {
                            guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else {
                                throw AFError.responseValidationFailed(reason: .dataFileNil)
                            }
                            guard let header = response.response?.allHeaderFields as? [String: String], let url = response.response?.url else {
                                throw AFError.responseValidationFailed(reason: .dataFileNil)
                            }
                            guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: header, for: url).first?.value else {
                                throw AFError.responseValidationFailed(reason: .dataFileNil)
                            }
                            promise(.success(IksmSession.Response(iksmSession: iksmSession, nsaid: nsaid)))
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

    // リクエストを実行
    public func publish<T: RequestType>(_ request: T) -> AnyPublisher<T.ResponseType, AFError> {
//        session.request(request, interceptor: self)
//            .validate()
//            .validate(contentType: ["application/json", "text/javascript"])
//            .responseDecodable(of: T.ResponseType.self, queue: DispatchQueue.main, dataPreprocessor: self, decoder: decoder, completionHandler: { response in
//                print(response)
//            })
        return session.request(request, interceptor: self)
            .validate()
            .validate(contentType: ["application/json", "text/javascript"])
            .publishDecodable(type: T.ResponseType.self, queue: DispatchQueue.main, preprocessor: self, decoder: decoder)
            .value()
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
