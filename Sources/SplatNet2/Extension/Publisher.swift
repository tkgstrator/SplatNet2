//
//  Publisher.swift
//  
//
//  Created by devonly on 2022/02/13.
//

import CocoaLumberjackSwift
import Combine
import Foundation

public extension Publisher {
    /// AFError -> SP2Error
    func mapToSP2Error(delegate: SplatNet2SessionDelegate?) -> Publishers.MapError<Self, SP2Error> {
        mapError({ error -> SP2Error in
            DDLogError(error)
            guard let sp2Error = error.asSP2Error else {
                return SP2Error.requestAdaptionFailed
            }
            delegate?.failedWithSP2Error(error: sp2Error)
            return sp2Error
        })
    }
}
