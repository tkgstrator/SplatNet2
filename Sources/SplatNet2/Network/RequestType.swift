//
//  RequestType.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.

import Alamofire
import Foundation

public protocol RequestType: URLRequestConvertible, RequestInterceptor {
    associatedtype ResponseType: Codable
    
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var path: String { get }
    var headers: [String: String]? { get set }
    var baseURL: URL { get }
    var encoding: ParameterEncoding { get }
}

extension RequestType {
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    }
    
    
    public var encoding: ParameterEncoding {
        JSONEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
        // swiftlint:disable:next force_unwrapping
        var request = URLRequest(url: URL(unsafeString: baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = TimeInterval(5)

        if let params = parameters {
            request = try encoding.encode(request, with: params)
        }
        return request
    }
}
