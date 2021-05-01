//
//  File.swift
//  
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {
    
    // Error Response
    // [400] Expired
    @discardableResult
    public func getResultCoop(jobId: Int) -> Future<Response.ResultCoop, APIError> {
        let request = ResultCoop(jobId: jobId)
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
                    promise(.success(response))
                })
                .store(in: &task)
        }
    }

    @discardableResult
    public func getSummaryCoop() -> Future<Response.SummaryCoop, APIError> {
        let request = SummaryCoop()
        return remote(request: request)
    }

    @discardableResult
    public func getNicknameAndIcons(playerId: [String]) -> Future<Response.NicknameIcons, APIError> {
        let request = NicknameIcons(playerId: playerId)
        return remote(request: request)
    }

    @discardableResult
    public func getCookie(sessionToken: String) -> Future<Response.UserInfo, APIError> {
        self.sessionToken = sessionToken
        return getCookie()
    }
    
    @discardableResult
    public func getCookie(sessionTokenCode: String) -> Future<Response.UserInfo, APIError> {
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
                }, receiveValue: { response in
                    let sessionToken = response.sessionToken
                    getCookie(sessionToken: sessionToken)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in }, receiveValue: { response in
                            promise(.success(response))
                        })
                        .store(in: &task)
                })
                .store(in: &task)
        }
    }

    @discardableResult
    public func getCookie() -> Future<Response.UserInfo, APIError> {
        let request = AccessToken()
        return Future { [self] promise in
            remote(request: request)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                        promise(.failure(error))
                    }
                }, receiveValue: { (response: Response.AccessToken) in
//                    print("ACCESS TOKEN", response)
                    getSplatoonToken(accessToken: response.accessToken)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                print(error)
                                promise(.failure(error))
                            }
                        }, receiveValue: { response in
//                            print("SPLATOON TOKEN", response)
                            let accessToken = response.result.webApiServerCredential.accessToken
                            let nickname = response.result.user.name
                            let imageUri = response.result.user.imageUri
                            let membership = response.result.user.membership.active
                            let expiresIn = response.result.webApiServerCredential.expiresIn
                            getSplatoonAccessToken(splatoonToken: accessToken)
                                .receive(on: DispatchQueue.main)
                                .sink(receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):
                                        promise(.failure(error))
                                    }
                                }, receiveValue: { response in
//                                    print("SPLATOON ACCESS TOKEN", response)
                                    let accessToken = response.result.accessToken
                                    getIksmSession(accessToken: accessToken)
                                        .receive(on: DispatchQueue.main)
                                        .sink(receiveCompletion: { completion in
                                            switch completion {
                                            case .finished:
                                                break
                                            case .failure(let error):
                                                promise(.failure(error))
                                            }
                                        }, receiveValue: { response in
//                                            print("IKSM SESSION", response)
                                            self.iksmSession = response.iksmSession
                                            self.playerId = response.nsaid
                                            let userInfo = Response.UserInfo(iksmSession: self.iksmSession!, nsaid: self.playerId!, nickname: nickname, membership: membership, imageUri: imageUri, expiresIn: expiresIn)
                                            promise(.success(userInfo))
                                        })
                                        .store(in: &task)
                                })
                                .store(in: &task)
                        })
                        .store(in: &task)
                })
                .store(in: &task)
        }
    }
}
