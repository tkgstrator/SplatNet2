//
//  Error.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/12/21.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

public extension Error {
    var asSP2Error: SP2Error? {
        // Error -> SP2Error
        if let error = self as? SP2Error {
            return error
        }
        // Error -> AFError
        guard let error = self.asAFError else {
            return nil
        }

        // AFError -> SP2Error
        switch error {
        case .responseValidationFailed(reason: let reason):
            switch reason {
            case .customValidationFailed(error: let error):
                return error as? SP2Error
            default:
                return nil
            }
        case .requestAdaptationFailed(error: let reason):
            DDLogError(reason)
            return SP2Error.unacceptableStatusCode(statusCode: 404)
        default:
            return nil
        }
    }
}
