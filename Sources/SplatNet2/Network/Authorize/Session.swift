//  swiftlint:disable:this file_name
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
    public func getCoopSummary()
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
                    if response.summary.card.jobNum <= account.coop.jobNum {
                        promise(.failure(SP2Error.noNewResults))
                    }
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

    /// Get latest X-Product version from App Store
    public func getVersion()
    -> AnyPublisher<XVersion.Response, SP2Error> {
        let request = XVersion()
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
    open func getCoopResults()
    -> AnyPublisher<[Result.Response], SP2Error> {
        Future { [self] promise in
            getCoopSummary()
                .flatMap({ summary -> Publishers.Sequence<Range<Int>, Never> in
                    print(account.coop.jobNum, summary.summary.card.jobNum)
                    return Range(max(account.coop.jobNum + 1, summary.summary.card.jobNum - 49) ... summary.summary.card.jobNum).publisher
                })
                .flatMap(maxPublishers: .max(1), { publish(Result(resultId: $0)) })
                .collect()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("FINISHED")
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
