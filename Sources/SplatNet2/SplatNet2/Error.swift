//
//  File.swift
//  
//
//  Created by devonly on 2021/05/06.
//

import Foundation

public extension SplatNet2 {
    enum APIError: Error, Identifiable, CaseIterable {
        public var id: String? { errorDescription }
        case badrequests    // 400
        case unauthorized   // 401
        case forbidden      // 403
        case unavailable    // 404
        case method         // 405
        case acceptable     // 406
        case timeout        // 408
        case upgrade        // 426 X-Product Version is not acceptable
        case requests       // 429 Too many requests
        case failure        // Unacceptable status code/response type
        case response       // Invalid Format
        case decode         // JSONDecoder error
        case unknown        // Unknown error
        case grant          // Invalid GrantType for AccessToken
        case expired        // Expired IksmSession
        case empty          // Empty iksmSession, sessionToken
        case nonewresults   // No new results
    }
}


extension SplatNet2.APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badrequests:
            return "ERROR_BADREQUESTS".localized
        case .unauthorized:
            return "ERROR_UNAUTHORIZED".localized
        case .forbidden:
            return "ERROR_FORBIDDEN".localized
        case .unavailable:
            return "ERROR_UNAVAILABLE".localized
        case .method:
            return "ERROR_METHOD".localized
        case .acceptable:
            return "ERROR_UNACCEPTABLE".localized
        case .timeout:
            return "ERROR_TIMEOUT".localized
        case .failure:
            return "ERROR_FAILURE".localized
        case .decode:
            return "ERROR_DECODE".localized
        case .requests:
            return "ERROR_REQUESTS".localized
        case .upgrade:
            return "ERROR_UPGRADE".localized
        case .unknown:
            return "ERROR_UNKNOWN".localized
        case .grant:
            return "ERROR_GRANT".localized
        case .expired:
            return "ERROR_EXPIRED".localized
        case .empty:
            return "ERROR_EMPTY".localized
        case .nonewresults:
            return "ERROR_NONEWRESULTS".localized
        case .response:
            return "ERROR_RESPONSE".localized
        }
    }
}

extension String {
    var localized: String {
        let bundle = Bundle.module
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
