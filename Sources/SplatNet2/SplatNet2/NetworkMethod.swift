//
//  NetworkMethod.swift
//
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {
    // JSON取得
    func remote<T: RequestType>(request: T) -> Future<T.ResponseType, Error> {
        return Future { [self] promise in
            remote(request: request, promise: promise)
        }
    }
    
    // 失敗した場合セッショントークンの再生成を行う
    private func remote<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, Error>) -> ()) {
        Publisher.publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error as Response.ServerError):
                    print(error)
                    if error.status == 403 {
                        getCookie(request: request, promise: promise)
                    }
                case .failure(let error):
                    print(error)
                }
            },
            receiveValue: { response in
                promise(.success(response))
            })
            .store(in: &task)
    }
    
    // 再要求を行わないリクエスト
    private func resend<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, Error>) -> ()) {
        Publisher.publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error as Response.ServerError):
                    print(error)
                    promise(.failure(APIError.upgrade))
                case .failure(let error as SplatNet2.APIError):
                    print(error)
                    promise(.failure(error))
                case .failure(let error):
                    print(error)
                    promise(.failure(APIError.upgrade))
                }
            },
            receiveValue: { response in
                promise(.success(response))
            })
            .store(in: &task)
    }
    
    // IKSM SESSIONを上書きして再リクエスト
    private func getCookie<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, Error>) -> ()) {
        getCookie()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                    print(error)
                }
            }, receiveValue: { [self] response in
                self.iksmSession = response.iksmSession
                var request = request
                request.headers = ["cookie": "iksm_session=\(iksmSession!)"]
                resend(request: request, promise: promise)
            })
            .store(in: &task)
    }
    
    // IKSM SESSION取得
    func generate<Request: IksmSession>(request: Request) -> Future<Response.IksmSession, Error> {
        return Future { [self] promise in
            generate(request: request, promise: promise)
        }
    }
    
    private func generate<Request: IksmSession>(request: Request, promise: @escaping (Result<Response.IksmSession, Error>) -> ()) {
        Publisher.generate(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            },
            receiveValue: { response in
                promise(.success(response))
            })
            .store(in: &task)
    }
}
