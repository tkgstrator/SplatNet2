//
//  APIError.swift
//  
//
//  Created by tkgstrator on 2021/05/06.
//

import Foundation

public enum APIError: Int, Error, Identifiable {
    public var id: Int { rawValue }
    case badrequest     = 400
    case unauthorized   = 401
    case forbidden      = 403
    case notfound       = 404
    case notallowed     = 405
    case unacceptable   = 406
    case timeout        = 408
    case upgrade        = 427
    case manyrequests   = 429
    case nonewresults   = 430
    case undecodable    = 432
    case response       = 433
    case unavailable    = 503
    case fatalerror     = 999
    
    var statusCode: Int {
        rawValue
    }
    
    /// エラーの概要を返す
    public var error: String {
        switch self {
        case .badrequest:
            return "400: Invalid request"
        case .unauthorized:
            return "401: Unauthorized"
        case .forbidden:
            return "403: Forbidden"
        case .notfound:
            return "404: Not found"
        case .notallowed:
            return "405: Not allowed"
        case .unacceptable:
            return "406: Unacceptable"
        case .timeout:
            return "408: Timeout"
        case .upgrade:
            return "427: Upgrade required"
        case .manyrequests:
            return "429: Too many requests"
        case .nonewresults:
            return "430: No new results"
        case .undecodable:
            return "432: Unsupported format"
        case .response:
            return "433: Invalid response"
        case .unavailable:
            return "503: Server unavailable"
        case .fatalerror:
            return "999: Fatal Error"
        }
    }
    
    struct Response: Codable {
        let errorMessage: String
        let statusCode: Int
        let correlationId: String
    }
}

extension APIError: LocalizedError {
    /// エラーの詳細を返す
    public var errorDescription: String? {
        switch self {
        case .badrequest:
            return "The provided session_token_code is expired."
        case .unauthorized:
            return "Client authentication failed."
        case .forbidden:
            return "The provided grant is invalid."
        case .notfound:
            return "No resources were found."
        case .notallowed:
            return "The requested method is not allowed."
        case .unacceptable:
            return "The request is not acceptable."
        case .timeout:
            return "The server did not response in time."
        case .upgrade:
            return "This X-Product version is no longer available."
        case .manyrequests:
            return "Too many requests."
        case .nonewresults:
            return "No new results"
        case .undecodable:
            return "The response from server could not decoded."
        case .response:
            return "The response from server is invalid format."
        case .unavailable:
            return "The server is currently unavailable."
        case .fatalerror:
            return "Fatal error."
        }
    }
}

extension String {
    var localized: String {
        let bundle = Bundle.module
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
