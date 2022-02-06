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
    //  swiftlint:disable:next discouraged_optional_collection
    var headers: [String: String]? { get set }
    var baseURL: URL { get }
    var encoding: ParameterEncoding { get }
}

public extension RequestType {
    var encoding: ParameterEncoding {
        JSONEncoding.default
    }

    var baseURL: URL {
        URL(unsafeString: "https://app.splatoon2.nintendo.net/api/")
    }

    func asURLRequest() throws -> URLRequest {
        // swiftlint:disable:next force_unwrapping
        var request = URLRequest(url: URL(unsafeString: baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(5)
        request.allHTTPHeaderFields = headers
        request.headers.update(.userAgent("SplatNet2/@tkgling"))
        if let params = parameters {
            return try encoding.encode(request, with: params)
        }
        return request
    }
}
