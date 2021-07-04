//
//  NetworkMethod.swift
//
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {
    
    internal func generate<T: IksmSession>(request: T) -> Future<T.ResponseType, APIError> {
        return SplatNet2.generate(request)
    }
    
    internal func remote<T: RequestType>(request: T) -> Future<T.ResponseType, APIError> {
        return Future { [self] promise in
            remote(request: request, promise: promise)
        }
    }
    
    internal func remote<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
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

    internal func generate(request: IksmSession, retry: Bool = false, promise: @escaping (Result<Response.IksmSession, APIError>) -> ()) {
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
                promise(.success(response))
            })
            .store(in: &task)
    }
    
    // 失敗した場合セッショントークンの再生成を行う
    internal func remote<T: RequestType>(request: T, retry: Bool = false, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
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
