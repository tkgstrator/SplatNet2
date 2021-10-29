//
//  NetworkMethod.swift
//
//
//  Created by tkgstrator on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {
    
    internal func generate<T: IksmSession>(request: T) -> Future<T.ResponseType, APIError> {
        return SplatNet2.generate(request)
    }
    
    public func remote<T: RequestType>(request: T) -> Future<T.ResponseType, APIError> {
        return Future { [self] promise in
            remote(request: request, promise: promise)
        }
    }
    
    public func remote<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
        publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    switch error {
                    case .forbidden:
                        getCookie(request: request, promise: promise)
                    default:
                        promise(.failure(error))
                    }
                }
            },
            receiveValue: { response in
                promise(.success(response))
            })
            .store(in: &task)
    }

    internal func generate(request: IksmSession, retry: Bool = false, promise: @escaping (Result<IksmSession.Response, APIError>) -> ()) {
        publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            },
            receiveValue: { (response: IksmSession.Response) in
                promise(.success(response))
            })
            .store(in: &task)
    }
    
    // 失敗した場合セッショントークンの再生成を行う
//    public func remote<T: RequestType>(request: T, retry: Bool = false, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
//        SplatNet2.publish(request)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    break
//                case .failure(let error):
//                    promise(.failure(error))
//                }
//            },
//            receiveValue: { (response: T.ResponseType) in
//                print("REMOTE", response)
//                promise(.success(response))
//            })
//            .store(in: &task)
//    }
}
