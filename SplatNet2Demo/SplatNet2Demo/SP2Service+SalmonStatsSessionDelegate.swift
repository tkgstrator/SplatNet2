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
    private func uploadResults() -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error> {
        var results: [CoopResult.Response] = []
        return Future { [self] promise in
            session.getCoopResults()
            .flatMap({ response -> Publishers.Sequence<[[CoopResult.Response]], Never> in
                results = response
                return response.chunked(by: 10).publisher
            })
            .flatMap({ [self] in uploadResults(results: $0) })
            .collect()
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                let response: [UploadResult.Response] = response.flatMap({ $0 }).sorted(by: { $0.jobId < $1.jobId })
                promise(.success(zip(response, results).map({ ($0.0, $0.1) })))
            })
            .store(in: &task)
        }
        .eraseToAnyPublisher()
    }

    public func uploadResults() {
        uploadResults()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                DDLogInfo(response.count)
            })
            .store(in: &task)
    }

    public func uploadResult(resultId: Int) -> AnyPublisher<[UploadResult.Response], SP2Error> {
        session.getCoopResult(resultId: resultId)
            .flatMap({ [self] in uploadResult(result: $0) })
            .eraseToAnyPublisher()
    }

    public func uploadResult() {
        uploadResult(resultId: 1_970)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                DDLogInfo(response)
            })
            .store(in: &task)
    }

    /// プレイヤーのメタデータ取得
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

    /// リザルト取得
    public func getResult() {
        getResult(resultId: 1_000_000)
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
