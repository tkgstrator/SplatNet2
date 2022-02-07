//
//  SP2Error.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/05/06.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

public protocol FailureResponse: Codable {
    var reason: SP2Error.ResponseValidationFailureReason? { get }
}

public enum SP2Error: Error {
    /// 新しいリザルトがない
    case noNewResults
    /// 指定されたリザルトIDがない
    case invalidResultId
    /// リクエストが誤っている
    case requestAdaptionFailed
    /// エラー形式のJSONに変換できた
    case responseValidationFailed(failure: FailureResponse)
    /// OAuthの認証でエラー発生
    case oauthValidationFailed(reason: OAuthValidationFailureReason)
    /// データのデコードができない
    case dataDecodingFailed
    /// 受理できないステータスコード
    case unacceptableStatusCode(statusCode: Int)
    /// 認証データが誤っている
    case credentialFailed

    public enum OAuthValidationFailureReason: CaseIterable {
        case stateMatchFailed
        case domainMatchFailed
        case invalidSessionState
        case invalidState
        case invalidSessionTokenCode

        public var statusCode: Int {
            switch self {
            case .stateMatchFailed:
                return 8_400
            case .domainMatchFailed:
                return 8_401
            case .invalidSessionState:
                return 8_402
            case .invalidState:
                return 8_403
            case .invalidSessionTokenCode:
                return 8_404
            }
        }
    }

    public enum ResponseValidationFailureReason: String {
        case invalidRequest     = "invalid_request"
        case invalidGrant       = "invalid_grant"
        case invalidClient      = "invalid_client"
        case badrequest         = "Bad request."
        case upgradeRequired    = "Upgrade required."
        case invalidToken       = "Invalid token."
        case expiredToken       = "Token expired."
        case unauthorized       = "Unauthorized."
        case tooManyRequests    = "Too many requests."
        case malformedUserAgent = "Malformed user agent."

        public var statusCode: Int {
            switch self {
            case .invalidRequest:
                return 9_400
            case .invalidGrant:
                return 9_401
            case .invalidClient:
                return 9_402
            case .badrequest:
                return 9_405
            case .upgradeRequired:
                return 9_427
            case .invalidToken:
                return 9_403
            case .expiredToken:
                return 9_404
            case .unauthorized:
                return 9_406
            case .tooManyRequests:
                return 9_429
            case .malformedUserAgent:
                return 9_407
            }
        }
    }

    /// エラーレスポンス
    public enum Failure {
        /// NSO用のエラーレスポンス
        public struct NSO: FailureResponse {
            public let errorDescription: String
            public let error: String
            public var reason: SP2Error.ResponseValidationFailureReason? {
                ResponseValidationFailureReason(rawValue: error)
            }
        }
        /// APP用のエラーレスポンス
        public struct APP: FailureResponse {
            public let errorMessage: String
            public let status: Int
            public let correlationId: String
            public var reason: SP2Error.ResponseValidationFailureReason? {
                ResponseValidationFailureReason(rawValue: errorMessage)
            }
        }

        /// S2S用のエラーレスポンス
        public struct S2S: FailureResponse {
            public let error: String
            public var reason: SP2Error.ResponseValidationFailureReason? {
                ResponseValidationFailureReason(rawValue: error)
            }
        }
    }

    public var errorCode: Int {
        switch self {
        case .noNewResults:
            return 0
        case .invalidResultId:
            return 1
        case .requestAdaptionFailed:
            return 5_000
        case .responseValidationFailed(let failure):
            return failure.reason?.statusCode ?? 9_999
        case .oauthValidationFailed(let reason):
            return reason.statusCode
        case .dataDecodingFailed:
            return 6_000
        case .unacceptableStatusCode(let statusCode):
            return statusCode
        case .credentialFailed:
            return 7_000
        }
    }
}

extension SP2Error: Identifiable {
    public var id: Int { self.errorCode }
}

extension SP2Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noNewResults:
            return "No new results."
        case .invalidResultId:
            return "Invalid result id."
        case .requestAdaptionFailed:
            return "Request adaption failed."
        case .responseValidationFailed(let failure):
            return failure.reason?.rawValue
        case .oauthValidationFailed(let reason):
            return "OAuth validation failed."
        case .dataDecodingFailed:
            return "Response data decoding failed."
        case .unacceptableStatusCode(let statusCode):
            return "Unacceptable status code \(statusCode)"
        case .credentialFailed:
            return "Invalid credential."
        }
    }
}
