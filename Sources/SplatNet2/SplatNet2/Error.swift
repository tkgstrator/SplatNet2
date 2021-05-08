//
//  File.swift
//  
//
//  Created by devonly on 2021/05/06.
//

import Foundation

public extension SplatNet2 {
    public enum APIError: Error {
        case failure        // Unacceptable status code/response type
        case json           // Invalid JSON Format
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
    }
}
