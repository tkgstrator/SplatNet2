//
//  DataRequest.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Foundation

public extension DataRequest {
    @discardableResult
    func validationWithSP2Error(decoder: JSONDecoder) -> Self {
        validate({ request, response, data in
            DataRequest.ValidationResult(catching: {
                if let data = data {
                    #if DEBUG
                    DDLogInfo("Status Code \(response.statusCode)")
                    let response = try JSONSerialization.jsonObject(with: data)
                    DDLogInfo(response)
                    #endif
                    if let failure = try? decoder.decode(SP2Error.Failure.NSO.self, from: data) {
                        throw SP2Error.responseValidationFailed(failure: failure)
                    }
                    if let failure = try? decoder.decode(SP2Error.Failure.APP.self, from: data) {
                        throw SP2Error.responseValidationFailed(failure: failure)
                    }
                    if let failure = try? decoder.decode(SP2Error.Failure.S2S.self, from: data) {
                        throw SP2Error.responseValidationFailed(failure: failure)
                    }
                    if let failure = try? decoder.decode(SP2Error.Failure.STATS.self, from: data) {
                        throw SP2Error.responseValidationFailed(failure: failure)
                    }
                }
                if (response.statusCode < 200) || (response.statusCode >= 400) {
                    throw SP2Error.unacceptableStatusCode(statusCode: response.statusCode)
                }
            })
        })
    }
}
