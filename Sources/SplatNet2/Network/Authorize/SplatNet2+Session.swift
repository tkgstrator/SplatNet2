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
import Foundation

extension SplatNet2 {
    /// Download coop results summary from SplatNet2
    public func getCoopSummary(resultId: Int = 0)
    -> AnyPublisher<Results.Response, SP2Error> {
        let request = Results()
        return Future { [self] promise in
            publish(request)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    DDLogInfo("Summary: \(resultId) -> \(response.summary.card.jobNum)")
                    // No new results
                    if response.summary.card.jobNum == resultId {
                        promise(.failure(SP2Error.noNewResults))
                    }
                    // Invalid RequestId
                    if response.summary.card.jobNum < resultId {
                        promise(.failure(SP2Error.invalidRequestId))
                    }
                    account?.coop = CoopInfo(from: response)
                    promise(.success(response))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }

    /// Download a specific coop result selected by result id from SplatNet2
    public func getCoopResult(resultId: Int)
    -> AnyPublisher<Result.Response, SP2Error> {
        let request = Result(resultId: resultId)
        return publish(request)
    }

    public static let schedule: [Schedule.Response] = {
        let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()
        guard let url = Bundle.module.url(forResource: "coop", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let schedule = try? decoder.decode([Schedule.Response].self, from: data) else {
                  return []
              }
        return schedule
    }()

    /// Download all gettable coop results from SplatNet2
    open func getCoopResults(resultId: Int? = nil)
    -> AnyPublisher<[Result.Response], SP2Error> {
        guard let account = account else {
            return Fail(outputType: [Result.Response].self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        // 取得するバイトIDを決定する
        let resultId: Int = {
            // 一度もバイトしたことがないアカウントは0として扱う
            guard let jobNum = account.coop.jobNum else {
                return 0
            }
            guard let resultId = resultId else {
                return jobNum
            }
            return resultId
        }()
        print(resultId)

        return Future { [self] promise in
            getCoopSummary(resultId: resultId)
                .flatMap({
                    Range(max(resultId + 1, $0.summary.card.jobNum - 49) ... $0.summary.card.jobNum).publisher
                })
                .flatMap(maxPublishers: .max(1), { publish(Result(resultId: $0)) })
                .collect()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(.success(response))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }
}
