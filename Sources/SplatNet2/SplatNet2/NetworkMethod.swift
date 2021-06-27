//
//  NetworkMethod.swift
//
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {
    
    internal func generate<T: IksmSession>(request: T) -> Future<T.ResponseType, Error> {
        return SplatNet2.generate(request)
    }
    
    internal func remote<T: RequestType>(request: T) -> Future<T.ResponseType, Error> {
        return SplatNet2.publish(request)
    }

    private func generate(request: IksmSession, retry: Bool = false, promise: @escaping (Result<Response.IksmSession, Error>) -> ()) {
        SplatNet2.publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error as Response.ServerError):
                    promise(.failure(error))
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
    private func remote<T: RequestType>(request: T, retry: Bool = false, promise: @escaping (Result<T.ResponseType, Error>) -> ()) {
        SplatNet2.publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error as Response.ServerError):
                    promise(.failure(error))
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
    
//    // IKSM SESSIONを上書きして再リクエスト
//    private func getCookie<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, Error>) -> Void) {
//        getCookie(sessionToken: sessionToken!)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    break
//                case .failure(let error):
//                    promise(.failure(error))
//                }
//            }, receiveValue: { [self] response in
//                self.iksmSession = response.iksmSession
//                var request = request
//                request.headers = ["cookie": "iksm_session=\(iksmSession!)"]
//                remote(request: request, retry: true, promise: promise)
//            })
//            .store(in: &task)
//    }
}
