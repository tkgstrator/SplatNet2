//
//  SalmonStats.swift
//  SalmonStats
//
//  Created by tkgstrator on 2021/04/10.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//  

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation
import KeychainAccess
import SplatNet2

public class SalmonStats: SplatNet2 {

    private func uploadResults(results: [CoopResult.Response]) -> AnyPublisher<[SalmonResult], SP2Error> {
        publish(UploadResult(results: results))
            .map({ zip($0.results, results).compactMap({ SalmonResult(upload: $0.0, result: $0.1) }) })
            .eraseToAnyPublisher()
    }

    /// リザルトアップロード
    private func uploadResults(resultId: Int?) -> AnyPublisher<[SalmonResult], SP2Error> {
        // Return -> AnyPublisher<[CoopResult.Response], SP2Error>
        getCoopResults(resultId: resultId)
            // Return -> AnyPublisher<[UploadResult.Response], SP2Error>
            .flatMap({ self.uploadResults(results: $0) })
            .eraseToAnyPublisher()
    }

    public func uploadResults(resultId: Int) {
        uploadResults(resultId: resultId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    DDLogError(error)
                }
            }, receiveValue: { response in
                if let delegate = self.delegate as? SalmonStatsSessionDelegate {
                    delegate.didFinishLoadResultsFromSplatNet2(results: response)
                }
            })
            .store(in: &task)
    }
}

public extension RequestType {
    var baseURL: URL {
        #if DEBUG
        URL(unsafeString: "http://localhost:3000/v1/")
        #else
        URL(unsafeString: "https://api.splatnet2.com/v1/")
        #endif
    }
}
