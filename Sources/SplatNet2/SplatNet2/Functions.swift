//
//  Functions.swift
//  
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {
    
    @discardableResult
    public func getResultCoop(jobId: Int) -> Future<SplatNet2.Coop.Result, Response.APIError> {
        let request = ResultCoop(iksmSession: account?.iksmSession, jobId: jobId)
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
    public func getResultCoopWithJSON(jobId: Int) -> Future<(json: Response.ResultCoop, data: SplatNet2.Coop.Result), Response.APIError> {
        let request = ResultCoop(iksmSession: account?.iksmSession, jobId: jobId)
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
    public func getSummaryCoop() -> Future<Response.SummaryCoop, Response.APIError> {
        let request = SummaryCoop(iksmSession: account?.iksmSession)
        return remote(request: request)
    }

    @discardableResult
    public func getNicknameAndIcons(playerId: [String]) -> Future<Response.NicknameIcons, Response.APIError> {
        let request = NicknameIcons(iksmSession: account?.iksmSession, playerId: playerId)
        return remote(request: request)
    }

    @discardableResult
    public func getCookie() -> Future<Response.UserInfo, Response.APIError> {
        return Future { [self] promise in
            if let sessionToken = account?.sessionToken {
                getCookie(sessionToken: sessionToken)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }, receiveValue: { response in
                        // Keychainに保存
                        account = response
                        keychain.setValue(account: response)
                        promise(.success(response))
                    }).store(in: &task)
            } else {
                promise(.failure(APIError.emptySessionToken))
            }
        }
    }
    
    // MARK: セッショントークンコードからイカスミセッションを取得
    @discardableResult
    public func getCookie(sessionTokenCode: String) -> Future<Response.UserInfo, Response.APIError> {
        return Future { [self] promise in
            getSessionToken(sessionTokenCode: sessionTokenCode)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { [self] response in
                    let sessionToken = response.sessionToken
                    getCookie(sessionToken: sessionToken)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }, receiveValue: { response in
                            // Keychainに保存
                            account = response
                            keychain.setValue(account: response)
                            promise(.success(response))
                        }).store(in: &task)
                }).store(in: &task)
        }
    }

    // MARK: セッショントークンからイカスミセッションを生成
    @discardableResult
    public func getCookie(sessionToken: String) -> Future<Response.UserInfo, Response.APIError> {
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        return Future { [self] promise in
            getAccessToken(sessionToken: sessionToken)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { [self] response in
                    let accessToken = response.accessToken
                    getS2SHash(accessToken: accessToken, timestamp: timestamp)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }, receiveValue: { [self] response in
                            getParameterF(accessToken: accessToken, hash: response, timestamp: timestamp, type: .nso)
                                .receive(on: DispatchQueue.main)
                                .sink(receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):
                                        promise(.failure(error))
                                    }
                                }, receiveValue: { response in
                                    getSplatoonToken(parameter: response)
                                        .receive(on: DispatchQueue.main)
                                        .sink(receiveCompletion: { completion in
                                            switch completion {
                                            case .finished:
                                                break
                                            case .failure(let error):
                                                promise(.failure(error))
                                            }
                                        }, receiveValue: { response in
                                            let splatoonTokenResponse = response
                                            let splatoonToken = response.result.webApiServerCredential.accessToken
                                            getS2SHash(accessToken: splatoonToken, timestamp: timestamp)
                                                .receive(on: DispatchQueue.main)
                                                .sink(receiveCompletion: { completion in
                                                    switch completion {
                                                    case .finished:
                                                        break
                                                    case .failure(let error):
                                                        promise(.failure(error))
                                                    }
                                                }, receiveValue: { response in
                                                    getParameterF(accessToken: splatoonToken, hash: response, timestamp: timestamp, type: .app)
                                                        .receive(on: DispatchQueue.main)
                                                        .sink(receiveCompletion: { completion in
                                                            switch completion {
                                                            case .finished:
                                                                break
                                                            case .failure(let error):
                                                                promise(.failure(error))
                                                            }
                                                        }, receiveValue: { response in
                                                            getSplatoonAccessToken(splatoonToken: splatoonToken, parameter: response)
                                                                .receive(on: DispatchQueue.main)
                                                                .sink(receiveCompletion: { completion in
                                                                    switch completion {
                                                                    case .finished:
                                                                        break
                                                                    case .failure(let error):
                                                                        promise(.failure(error))
                                                                    }
                                                                }, receiveValue: { response in
                                                                    getIksmSession(from: response)
                                                                        .receive(on: DispatchQueue.main)
                                                                        .sink(receiveCompletion: { completion in
                                                                            switch completion {
                                                                            case .finished:
                                                                                break
                                                                            case .failure(let error):
                                                                                promise(.failure(error))
                                                                            }
                                                                        }, receiveValue: { response in
                                                                            promise(.success(Response.UserInfo(sessionToken: sessionToken, response: response, splatoonToken: splatoonTokenResponse)))
                                                                        }).store(in: &task)
                                                                }).store(in: &task)
                                                        }).store(in: &task)
                                                }).store(in: &task)
                                        }).store(in: &task)
                                }).store(in: &task)
                        }).store(in: &task)
                }).store(in: &task)
        }
    }
}
