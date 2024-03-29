//
//  SplatNet2+Session.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/06/27.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation

extension SplatNet2 {
    /// Download coop results summary from SplatNet2
    public func getCoopSummary(resultId: Int = 0)
    -> AnyPublisher<CoopSummary.Response, SP2Error> {
        let request = CoopSummary()
        return publish(request)
            .tryMap({ response in
                // 新しいリザルトがない
                if response.summary.card.jobNum == resultId {
                    throw SP2Error.noNewResults
                }
                // 不正なリザルトID
                if response.summary.card.jobNum < resultId {
                    throw SP2Error.invalidResultId
                }
                return response
            })
            .mapToSP2Error(delegate: delegate)
            .eraseToAnyPublisher()
    }

    /// Download a specific coop result selected by result id from SplatNet2
    public func getCoopResult(resultId: Int)
    -> AnyPublisher<CoopResult.Response, SP2Error> {
        let request = CoopResult(resultId: resultId)
        return publish(request)
    }

    public static let schedule: [Schedule.Response] = {
        let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()
        do {
            guard let url = Bundle.module.url(forResource: "coop", withExtension: "json") else {
                return []
            }
            let data = try Data(contentsOf: url)
            return try decoder.decode([Schedule.Response].self, from: data)
        } catch {
            DDLogError(error)
            return []
        }
    }()

    /// Download all gettable coop results from SplatNet2
    open func getCoopResults(resultId: Int? = nil)
    -> AnyPublisher<[CoopResult.Response], SP2Error> {
        guard let _ = account else {
            return Fail(outputType: [CoopResult.Response].self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        // 取得するバイトIDを決定する
        let resultId: Int = {
            guard let resultId = resultId else {
                return 0
            }
            return resultId
        }()

        return getCoopSummary(resultId: resultId)
            .flatMap({ response -> Publishers.Sequence<Range<Int>, Never> in
                let maximum: Int = response.summary.card.jobNum
                let current: Int = max(resultId + 1, response.summary.card.jobNum - 49)
                self.delegate?.isAvailableResults(current: current, maximum: maximum)
                return Range(current ... maximum).publisher
            })
            .flatMap(maxPublishers: .max(1), { self.publish(CoopResult(resultId: $0)) })
            .handleEvents(
                receiveOutput: { response in
                    if let jobId = response.jobId {
                        self.delegate?.isGettingResultId(current: jobId)
                    }
                }
            )
            .collect()
            .eraseToAnyPublisher()
    }
}
