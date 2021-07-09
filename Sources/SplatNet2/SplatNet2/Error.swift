//
//  APIError.swift
//  
//
//  Created by devonly on 2021/05/06.
//

import Foundation

public struct APIError: Codable, Error, Identifiable {
    public var id: UUID { UUID() }
    public var statusCode: Int?
    public var error: String?
    public var errorDescription: String?
    public var status: Int?
    public var errorMessage: String?
    public var correlationId: String?
    public var message: String?            // https://app.splatoon2.nintendo.net/api
    public var code: String?               // https://app.splatoon2.nintendo.net/api
    public var response: [String: String]? // Error Response
}

extension APIError: LocalizedError, CustomNSError {
    public var localizedDescription: String {
        if let errorDescription = errorDescription {
            return errorDescription
        }
        if let message = message {
            return message
        }
        if let error = error {
            return error
        }
        return "ERROR_UNKNOWN"
    }
    
    public static var nonewresults: APIError {
        var apiError = APIError()
        apiError.statusCode = 9404
        apiError.errorDescription = "ERROR_NO_NEWRESULTS"
        return apiError
    }

    public static var timeout: APIError {
        var apiError = APIError()
        apiError.statusCode = 408
        apiError.errorDescription = "ERROR_REQUEST_TIMEOUT"
        return apiError
    }
    
    public static var emptySessionToken: APIError {
        var apiError = APIError()
        apiError.statusCode = 403
        apiError.errorDescription = "ERROR_EMPTY_SESSIONTOKEN"
        return apiError
    }
    
    public static var invalidAccount: APIError {
        var apiError = APIError()
        apiError.statusCode = 999
        apiError.errorDescription = "ERROR_INVALID_ACCOUNT"
        return apiError
    }
    
    public static var invalidIksmSession: APIError {
        var apiError = APIError()
        apiError.statusCode = 403
        apiError.errorDescription = "ERROR_INVALID_IKSMSESSION"
        return apiError
    }

    public static func invalidResponse(error: Error) -> APIError {
        var apiError = APIError()
        apiError.statusCode = 666
        apiError.errorDescription = error.localizedDescription
        return apiError
    }
    
    public static func invalidResponse(from response: String) -> APIError {
        var apiError = APIError()
        apiError.statusCode = 666
        apiError.errorDescription = "ERROR_INVALID_RESPONSE"
        apiError.response = ["response": response]
        return apiError
    }

    public static func invalidResponse(from response: Data) -> APIError {
        var apiError = APIError()
        apiError.statusCode = 666
        let response = (try? JSONSerialization.jsonObject(with: response) as? [String: Any])
        apiError.response = response?.compactMapValues({ $0 as? String })
        return apiError
    }

    public static func invalidJSON(error: Error, from response: Data) -> APIError {
        var apiError = APIError()
        apiError.statusCode = 666
        apiError.errorDescription = error.localizedDescription
        let response = (try? JSONSerialization.jsonObject(with: response) as? [String: Any])
        apiError.response = response?.compactMapValues({ $0 as? String })
        return apiError
    }
}

extension String {
    var localized: String {
        let bundle = Bundle.module
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
