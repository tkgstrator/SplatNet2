//
//  Session.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/06/27.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Combine
import Foundation

extension SplatNet2 {
    /// Download coop results summary from SplatNet2
    public func getCoopSummary() -> AnyPublisher<Results.Response, SP2Error> {
        let request = Results(iksmSession: iksmSession)
        return publish(request)
    }
    
    /// Download a specific coop result selected by result id from SplatNet2
    public func getCoopResult(resultId: Int) -> AnyPublisher<Result.Response, SP2Error> {
        let request = Result(iksmSession: iksmSession, jobId: resultId)
        return publish(request)
    }
    
    /// Get latest X-Product version from App Store
    public func getVersion() -> AnyPublisher<XVersion.Response, SP2Error> {
        let request = XVersion()
        return publish(request)
    }
    
    /// Download all gettable coop results from SplatNet2
    open func getCoopResults(resultId: Int) -> AnyPublisher<[Result.Response], SP2Error> {
        return Future { [self] promise in
            getCoopSummary()
                .flatMap({ Range((resultId + 1) ... $0.summary.card.jobNum).publisher })
                .flatMap({ publish(Result(iksmSession: iksmSession, jobId: $0)) })
                .collect()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("FINISHED")
                    case .failure(let error):
                        print("ERROR", error)
                    }
                }, receiveValue: { response in
                    promise(.success(response))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }
}
