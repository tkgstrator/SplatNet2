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
        case failure        // Unacceptable status code/response type
        case response       // Invalid Format
        case decode         // JSONDecoder could not decode
        case requests       //
        case unavailable    // Server is unavailable
        case upgrade        // X-Product Version needs to upgrade
        case unknown
        case badrequests    // Bad request
        case fatal          // fatal error
        case grant          // Invalid GrantType for AccessToken
        case s2shash        // Too many request
        case expired        // Expired IksmSession
        case empty          // Empty iksmSession, sessionToken
        case nonewresults
    }
}


extension SplatNet2.APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failure:
            return "ERROR_FAILURE".localized
        case .response:
            return "ERROR_RESPONSE".localized
        case .decode:
            return "ERROR_DECODE".localized
        case .requests:
            return "ERROR_REQUESTS".localized
        case .unavailable:
            return "ERROR_UNAVAILABLE".localized
        case .upgrade:
            return "ERROR_UPGRADE".localized
        case .unknown:
            return "ERROR_UNKNOWN".localized
        case .badrequests:
            return "ERROR_BADREQUESTS".localized
        case .fatal:
            return "ERROR_FATAL".localized
        case .grant:
            return "ERROR_GRANT".localized
        case .s2shash:
            return "ERROR_S2SHASH".localized
        case .expired:
            return "ERROR_EXPIRED".localized
        case .empty:
            return "ERROR_EMPTY".localized
        case .nonewresults:
            return "ERROR_NONEWRESULTS".localized
        }
    }
}

extension String {
    var localized: String {
        let bundle = Bundle.module
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
