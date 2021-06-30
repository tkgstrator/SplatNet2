//
//  NetworkMethod.swift
//
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {
//    typealias APIError = Response.APIError
    
    internal func generate<T: IksmSession>(request: T) -> Future<T.ResponseType, APIError> {
        return SplatNet2.generate(request)
    }
    
    internal func remote<T: RequestType>(request: T) -> Future<T.ResponseType, APIError> {
        return Future { [self] promise in
            remote(request: request, promise: promise)
        }
    }
    
    private func remote<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
        SplatNet2.publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if error.statusCode == 403 {
                        getCookie(request: request, promise: promise)
                    } else {
                        promise(.failure(error))
                    }
                }
            },
            receiveValue: { response in
                promise(.success(response))
            })
            .store(in: &task)
    }
    
    private func getCookie<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
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
                account = response
                keychain.setValue(account: response)
                
                var request = request
                request.headers = ["cookie": "iksm_session=\(response.iksmSession)"]
                remote(request: request, promise: promise)
            })
            .store(in: &task)
    }
    
    private func generate(request: IksmSession, retry: Bool = false, promise: @escaping (Result<Response.IksmSession, APIError>) -> ()) {
        SplatNet2.publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            },
            receiveValue: { (response: Response.IksmSession) in
                print("GENERATE", response)
                promise(.success(response))
            })
            .store(in: &task)
    }
    
    // 失敗した場合セッショントークンの再生成を行う
    private func remote<T: RequestType>(request: T, retry: Bool = false, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
        SplatNet2.publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            },
            receiveValue: { (response: T.ResponseType) in
                print("REMOTE", response)
                promise(.success(response))
            })
            .store(in: &task)
    }
}
