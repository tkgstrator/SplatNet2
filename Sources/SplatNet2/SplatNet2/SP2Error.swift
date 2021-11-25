//
//  SP2Error.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/05/06.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

public enum SP2Error: Error {
//    case explicitlyCancelled
    case noNewResults
    case userCancelled
//    case requestAdaptationFailed
//    case requestRetryFailed
    case responseValidationFailed(reason: ResponseValidationFailureReason, failure: FailureResponse?)
    case responseSerializationFailed
//    case urlRequestValidationFailed
    case oauthValidationFailed(reason: OAuthValidationFailureReason)
    case dataDecodingFailed

    public enum OAuthValidationFailureReason {
        case stateMatchFailed
        case domainMatchFailed
        case invalidSessionState
        case invalidState
        case invalidSessionTokenCode
    }

    public enum ResponseValidationFailureReason {
        case unacceptableStatusCode(code: HTTPError)
        case customValidationFailed
    }

    public enum HTTPError: Int {
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case notAllowed = 405
        case unacceptable = 406
        case timeout = 408
        case upgradeRequired = 427
        case manyRequests = 429
        case unavailable = 503
    }

    public var errorCode: Int {
        switch self {
        case .noNewResults:
            return 0
        case .userCancelled:
            return 1
        case .responseValidationFailed(let reason, let failure):
            if let failure = failure, let failureApp = failure as? Failure.APP {
                return failureApp.status
            } else {
                switch reason {
                case .unacceptableStatusCode(let code):
                    return code.rawValue
                case .customValidationFailed:
                    return 500
                }
            }
        case .oauthValidationFailed(let reason):
            switch reason {
            case .stateMatchFailed:
                return 8_401
            case .domainMatchFailed:
                return 8_402
            case .invalidSessionState:
                return 8_404
            case .invalidState:
                return 8_405
            case .invalidSessionTokenCode:
                return 8_406
            }
        case .dataDecodingFailed:
            return 9_400
        case .responseSerializationFailed:
            return 9_401
        }
    }

    /// エラーレスポンス
    public enum Failure {
        /// NSO用のエラーレスポンス
        public struct NSO: FailureResponse {
            public let errorDescription: String
            public let error: String
        }
        /// APP用のエラーレスポンス
        public struct APP: FailureResponse {
            public let errorMessage: String
            public let status: Int
            public let correlationId: String
        }
    }
}

public protocol FailureResponse: Codable {
}

extension SP2Error: Identifiable {
    public var id: Int { self.errorCode }
}

extension SP2Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noNewResults:
            return "No new results."
        case .userCancelled:
            return "Operation was cancelled by user."
        case .responseValidationFailed(_, let failure):
            if let failure = failure, let failureApp = failure as? Failure.APP {
                return failureApp.errorMessage
            } else {
                return "Response validation failed."
            }
        case .oauthValidationFailed(let reason):
            switch reason {
            case .stateMatchFailed:
                return "State does not matched."
            case .domainMatchFailed:
                return "Domain does not matched."
            case .invalidSessionState:
                return "Invalid session state."
            case .invalidState:
                return "Invalid state."
            case .invalidSessionTokenCode:
                return "Invalid session token code."
            }
        case .dataDecodingFailed:
            return "Invalid response."
        case .responseSerializationFailed:
            return "Invalid response."
        }
    }
}

extension String {
    var localized: String {
        let bundle = Bundle.module
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
