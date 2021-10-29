//
//  Functions.swift
//  
//
//  Created by tkgstrator on 2021/04/04.
//

import Foundation
import Combine
import KeychainAccess

extension SplatNet2 {
    
    @discardableResult
    public func getResultCoop(jobId: Int) -> Future<SplatNet2.Coop.Result, APIError> {
        return Future { [self] promise in
            let request = ResultCoop(iksmSession: iksmSession, jobId: jobId)
            remote(request: request)
                .subscribe(on: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(.success(Coop.Result(from: response)))
                })
                .store(in: &task)
        }
    }
    
    // 取得すべきリザルトIDの配列を返す
    @discardableResult
    private func getGettableResultIds(latestJobId: Int) -> Future<[Int], APIError> {
        return Future { [self] promise in
            getSummaryCoop(jobNum: latestJobId)
                .subscribe(on: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    let jobNum: Int = response.summary.card.jobNum
                    // 新規リザルトがなければエラーを返す
                    if jobNum == latestJobId {
                        promise(.failure(.nonewresults))
                    } else {
                        let jobIds: [Int] = (max(latestJobId + 1, jobNum - 49) ... jobNum).map({ $0 })
                        promise(.success(jobIds))
                    }
                })
                .store(in: &task)
        }
    }
    
    // シフトIDを指定してリザルトの配列を取得する
    public func getResultCoopWithJSON(latestJobId: Int, promise: @escaping (Result<(json: [ResultCoop.Response], data: [SplatNet2.Coop.Result]), APIError>) -> Void) {
        var json: [ResultCoop.Response] = []
        var data: [SplatNet2.Coop.Result] = []
        
        getGettableResultIds(latestJobId: latestJobId)
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }, receiveValue: { [self] jobIds in
                // 通知を送信
                NotificationCenter.default.post(name: SplatNet2.download, object: Progress(maxValue: jobIds.count, currentValue: 0))
                let publisher = jobIds.publisher
                publisher
                    .flatMap(maxPublishers: .max(1), { self.getResultCoopWithJSON(jobId: $0).delay(for: 1, scheduler: RunLoop.main) })
                    .subscribe(on: DispatchQueue.main)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            promise(.success((json: json, data: data)))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }, receiveValue: { response in
                        if let response = response {
                            json.append(response.json)
                            data.append(response.data)
                        }
                        // データを受け取るたびに通知を送信
                        NotificationCenter.default.post(name: SplatNet2.download, object: Progress(maxValue: jobIds.count, currentValue: json.count))
                    })
                    .store(in: &self.task)
            })
            .store(in: &task)
    }
    
    @discardableResult
    internal func getResultCoopWithJSON(jobId: Int) -> Future<(json: ResultCoop.Response, data: SplatNet2.Coop.Result)?, APIError> {
        return Future { [self] promise in
            let request = ResultCoop(iksmSession: iksmSession, jobId: jobId)
            remote(request: request)
                .subscribe(on: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .timeout(.seconds(3), scheduler: DispatchQueue.main, options: nil, customError:nil)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        switch error {
                        case .notfound:
                            promise(.success(nil))
                        default:
                            promise(.failure(error))
                        }
                    }
                }, receiveValue: { response in
                    promise(.success((json: response, data: Coop.Result(from: response))))
                })
                .store(in: &task)
        }
    }
    
    @discardableResult
    internal func getSummaryCoop(jobNum: Int = 0) -> Future<SummaryCoop.Response, APIError> {
        return Future { [self] promise in
            let request = SummaryCoop(iksmSession: iksmSession)
            remote(request: request)
                .subscribe(on: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { response in
                    account.update(from: response)
                    keychain.setValue(account)
                    promise(.success(response))
                })
                .store(in: &task)
        }
    }
    
    public func getNicknameAndIcons(playerId: [String], promise: @escaping (Result<[NicknameIcons.Response.NicknameIcon], APIError>) -> Void) {
        let playerIds: [[String]] = playerId.chunked(by: 200)
        var nicknames: [NicknameIcons.Response.NicknameIcon] = []
        
        playerIds
            .publisher
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .flatMap(maxPublishers: .max(1), { self.remote(request: NicknameIcons(iksmSession: self.iksmSession, playerId: $0)).eraseToAnyPublisher() })
            .timeout(.seconds(10), scheduler: DispatchQueue.main, options: nil, customError: nil)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    promise(.success(nicknames))
                case .failure(let error):
                    promise(.failure(error))
                }
            }, receiveValue: { response in
                nicknames.append(contentsOf: response.nicknameAndIcons)
                NotificationCenter.default.post(name: SplatNet2.download, object: Progress(maxValue: playerId.count, currentValue: nicknames.count))
            })
            .store(in: &task)
    }
    
    static public var shiftSchedule: [ScheduleCoop.Response] {
        let json = Bundle.module.url(forResource: "coop", withExtension: "json")!
        let data = (try? Data(contentsOf: json))!
        let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()
        let shift = (try? decoder.decode([ScheduleCoop.Response].self, from: data))!
        return shift
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
