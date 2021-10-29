//
//  Cookie.swift
//  
//
//  Created by tkgstrator on 2021/07/04.
//

import Foundation
import Combine
import KeychainAccess

extension SplatNet2 {
    
    internal func getCookie<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
        getCookie()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }, receiveValue: { [self] response in
                // アカウント情報を上書き
                account = response
                var request = request
                request.headers = ["cookie": "iksm_session=\(response.iksmSession)"]
                remote(request: request, promise: promise)
            })
            .store(in: &task)
    }
    
    @discardableResult
    internal func getCookie() -> Future<UserInfo, APIError> {
        return Future { [self] promise in
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
                    promise(.success(response))
                }).store(in: &task)
        }
    }
    
    /// セッショントークンコードからイカスミセッションを取得
    @discardableResult
    internal func getCookie(sessionTokenCode: String, verifier: String) -> Future<UserInfo, APIError> {
        let publisher = [sessionTokenCode].publisher
        
        return Future { [self] promise in
            publisher
                .flatMap({ getSessionToken(sessionTokenCode: $0, verifier: verifier) })
                .flatMap({ getCookie(sessionToken: $0.sessionToken) })
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
    }
    
    /// セッショントークンからスプラトゥーントークンを取得
    @discardableResult
    private func getSplatoonToken(sessionToken: String) -> Future<SplatoonToken.Response, APIError> {
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        let publisher = [sessionToken].publisher
        var accessToken: String = ""

        return Future { [self] promise in
            publisher
                .flatMap({ getAccessToken(sessionToken: $0) })
                .flatMap({ response -> AnyPublisher<S2SHash.Response, APIError> in
                    accessToken = response.accessToken
                    return getS2SHash(accessToken: accessToken, timestamp: timestamp, type: .nso)
                })
                .flatMap({ getParameterF(accessToken: accessToken, hash: $0, timestamp: timestamp, type: .nso) })
                .flatMap({ getSplatoonToken(parameter: $0) })
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { receiveValue in
                    promise(.success(receiveValue))
                })
                .store(in: &task)
        }
    }

    /// スプラトゥーントークンからスプラトゥーンアクセストークンを取得
    @discardableResult
    private func getSplatoonAccessToken(splatoonToken: String) -> Future<SplatoonAccessToken.Response, APIError> {
        let timestamp: Int = Int(Date().timeIntervalSince1970)
        let publisher = [splatoonToken].publisher

        return Future { [self] promise in
            publisher
                .flatMap({ getS2SHash(accessToken: $0, timestamp: timestamp, type: .app) })
                .flatMap({ getParameterF(accessToken: splatoonToken, hash: $0, timestamp: timestamp, type: .app) })
                .flatMap({ getSplatoonAccessToken(splatoonToken: splatoonToken, parameter: $0) })
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { receiveValue in
                    promise(.success(receiveValue))
                })
                .store(in: &task)
        }
    }

    // MARK: セッショントークンからイカスミセッションを生成
    @discardableResult
    public func getCookie(sessionToken: String) -> Future<UserInfo, APIError> {
        let publisher = [sessionToken].publisher
        var splatoonToken: SplatoonToken.Response?
        
        return Future { [self] promise in
            publisher
                .flatMap({ getSplatoonToken(sessionToken: $0) })
                .flatMap({ response -> AnyPublisher<SplatoonAccessToken.Response, APIError> in
                    splatoonToken = response
                    return getSplatoonAccessToken(splatoonToken: response.result.webApiServerCredential.accessToken).eraseToAnyPublisher()
                })
                .flatMap({ getIksmSession(from: $0) })
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }, receiveValue: { receiveValue in
                    let userinfo = UserInfo(sessionToken: sessionToken, response: receiveValue, splatoonToken: splatoonToken!)
                    addAccount(account: userinfo)
                    promise(.success(userinfo))
                })
                .store(in: &task)
        }
    }
}
