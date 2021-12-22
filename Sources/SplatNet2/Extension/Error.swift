//
//  Error.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/12/21.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

extension Error {
    var asSP2Error: SP2Error? {
        guard let error = self.asAFError else {
            return nil
        }

        switch error {
        case .responseValidationFailed(reason: let reason):
            switch reason {
            case .customValidationFailed(error: let error):
                return error as? SP2Error
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
