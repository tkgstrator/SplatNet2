//
//  SP2Service+SalmonStatsSessionDelegate.swift
//  SplatNet2Demo
//
//  Created by devonly on 2022/02/10.
//  Copyright © 2022 Magi, Inc. All rights reserved.
//

import CocoaLumberjackSwift
import Combine
import Foundation
import SalmonStats
import SplatNet2

#warning("適合するのはSplatNet2の方が良いかもしれない")
extension SP2Service: SalmonStatsSessionDelegate {
    public var apiToken: String? {
        get {
            session.keychain.getAPIToken()
        }
        set(newValue) {
            session.keychain.setAPIToken(apiToken: newValue)
        }
    }

    public func uploadResult(resultId: Int) -> AnyPublisher<[UploadResult.Response], SP2Error>? {
        fatalError()
    }

    public func uploadResults(resultId: Int?) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error>? {
        fatalError()
    }

    public func getPlayerMetadata() {
        getPlayerMetadata(nsaid: nsaid)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    DDLogError(error)
                }
            }, receiveValue: { response in
                DDLogInfo(response)
            })
            .store(in: &task)
    }
}
