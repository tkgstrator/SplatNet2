//
//  Functions.swift
//  
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine
import KeychainAccess

extension SplatNet2 {
    
    @discardableResult
    public func getResultCoop(jobId: Int) -> Future<SplatNet2.Coop.Result, APIError> {
        let request = ResultCoop(iksmSession: account.iksmSession, jobId: jobId)
        return Future { [self] promise in
            remote(request: request)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        break
                    }
                }, receiveValue: { response in
                    promise(.success(Coop.Result(from: response)))
                })
                .store(in: &task)
        }
    }

    @discardableResult
    public func getResultCoopWithJSON(jobId: Int) -> Future<(json: Response.ResultCoop, data: SplatNet2.Coop.Result), APIError> {
        let request = ResultCoop(iksmSession: account.iksmSession, jobId: jobId)
        return Future { [self] promise in
            remote(request: request)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        promise(.failure(error))
                    case .finished:
                        break
                    }
                }, receiveValue: { response in
                    promise(.success((json: response, data: Coop.Result(from: response))))
                })
                .store(in: &task)
        }
    }
    
    @discardableResult
    public func getSummaryCoop(jobNum: Int = 0) -> Future<Response.SummaryCoop, APIError> {
        let request = SummaryCoop(iksmSession: account.iksmSession)
        return Future { [self] promise in
            remote(request: request)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    if jobNum == response.summary.card.jobNum {
                        promise(.failure(APIError.nonewresults))
                    }
                    Keychain.update(summary: response)
                    // データを上書きする
                    promise(.success(response))
                }).store(in: &task)
        }
    }
    
    @discardableResult
    public func getNicknameAndIcons(playerId: [String]) -> Future<Response.NicknameIcons, APIError> {
        let request = NicknameIcons(iksmSession: account.iksmSession, playerId: playerId)
        return remote(request: request)
    }
    
    // ローカルファイルを参照しているだけなのでエラーが発生するはずがない
    @discardableResult
    public func getShiftSchedule() -> Future<[Response.ScheduleCoop], APIError> {
        return Future { promise in
            if let json = Bundle.module.url(forResource: "coop", withExtension: "json") {
                if let data = try? Data(contentsOf: json) {
                    let decoder: JSONDecoder = {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        return decoder
                    }()
                    
                    if let shift = try? decoder.decode([Response.ScheduleCoop].self, from: data) {
                        promise(.success(shift))
                    } else {
                        promise(.failure(APIError()))
                    }
                } else {
                    promise(.failure(APIError()))
                }
            } else {
                promise(.failure(APIError()))
            }
        }
    }
}
