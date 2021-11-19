//
//  RequestType.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.

import Alamofire
import Foundation
import SwiftUI

public protocol RequestType: URLRequestConvertible {
    associatedtype ResponseType: Codable

    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var path: String { get }
    var headers: [String: String]? { get set }
    var baseURL: URL { get }
    var encoding: ParameterEncoding { get }
}

extension SplatNet2: RequestInterceptor {
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(.userAgent("Salmonia3/tkgling"))
        urlRequest.headers.add(HTTPHeader(name: "cookie", value: "iksm_session=\(iksmSession)"))
        completion(.success(urlRequest))
    }

    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if request.retryCount < 1 {
        getCookie(sessionToken: sessionToken)
            .sink(receiveCompletion: { result in
                switch result {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                        completion(.doNotRetry)
                }
            }, receiveValue: { response in
                self.account = response
                completion(.doNotRetry)
            })
            .store(in: &task)
        }
    }
}

extension RequestType {
    public var encoding: ParameterEncoding {
        JSONEncoding.default
    }

    public func asURLRequest() throws -> URLRequest {
        // swiftlint:disable:next force_unwrapping
        var request = URLRequest(url: URL(unsafeString: baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(5)
        request.allHTTPHeaderFields = headers

        if let params = parameters {
            request = try encoding.encode(request, with: params)
        }
        return request
    }
}
