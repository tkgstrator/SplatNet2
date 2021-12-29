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
}

public enum SP2Error: Error {
//    case explicitlyCancelled
    case noNewResults
    case invalidRequestId
//    case userCancelled
//    case requestAdaptationFailed
//    case requestRetryFailed
    case responseValidationFailed(reason: ResponseValidationFailureReason, failure: FailureResponse?)
//    case responseSerializationFailed
//    case urlRequestValidationFailed
    case oauthValidationFailed(reason: OAuthValidationFailureReason)
    case dataDecodingFailed
    case credentialFailed

    public enum OAuthValidationFailureReason: Int {
        case stateMatchFailed = 8_000
        case domainMatchFailed = 8_001
        case invalidSessionState = 8_002
        case invalidState = 8_003
        case invalidSessionTokenCode = 8_004
    }

    public enum ResponseValidationFailureReason {
        case unacceptableStatusCode(code: Int)
//        case customValidationFailed
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
        /// S2S用のエラーレスポンス
        public struct S2S: FailureResponse {
            public let error: String
        }
    }

    public var errorCode: Int {
        switch self {
        case .noNewResults:
            return 0
        case .invalidRequestId:
            return 1
        case .responseValidationFailed(reason: let reason, _):
            switch reason {
            case .unacceptableStatusCode(code: let code):
                return code
            }
        case .oauthValidationFailed(reason: let reason):
            return reason.rawValue
        case .dataDecodingFailed:
            return 1_000
        case .credentialFailed:
            return 2_000
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
            case .invalidRequestId:
                return "Invalid request id."
            case .responseValidationFailed(_, let failure):
                if let failure = failure as? Failure.APP {
                    return failure.errorMessage
                }
                if let failure = failure as? Failure.NSO {
                    return failure.errorDescription
                }
                if let failure = failure as? Failure.S2S {
                    return failure.error
                }
                return "Unacceptable statusCode."
            case .oauthValidationFailed(_):
                return "Invalid credential."
            case .dataDecodingFailed:
                return "Invalid response."
            case .credentialFailed:
                return "No credential."
        }
    }
}
