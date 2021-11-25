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
    case explicitlyCancelled
    case requestAdaptationFailed
    case requestRetryFailed
    case responseValidationFailed(reason: ResponseValidationFailureReason, failure: FailureResponse?)
    case responseSerializationFailed
    case urlRequestValidationFailed
    case oauthValidationFailed(reason: OAuthValidationFailureReason)
    case dataDecodingFailed

    public enum OAuthValidationFailureReason {
        case stateMatchFailed
        case domainMatchFailed
        case userCancelled
        case invalidSessionState
        case invalidState
        case invalidSessionTokenCode
    }

    public enum ResponseValidationFailureReason {
        case dataFileNil
        case dataFileReadFailed
        case missingContentType
        case unacceptableContentType
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
        case noNewResults = 430
        case unavailable = 503
    }

    public var errorCode: Int {
        9_999
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

extension Error {
}

extension AFError {
}

extension String {
    var localized: String {
        let bundle = Bundle.module
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
