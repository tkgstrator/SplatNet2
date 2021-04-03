//
//  File 2.swift
//  
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {
//    func remote<Request: RequestProtocol>(request: Request, promise: @escaping (Result<Request.ResponseType, APIError>) -> Void) {
//        _ = NetworkPublisher.publish(request)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [self] completion in
//                switch completion {
//                case .finished:
//                    break
//                case .failure(let error):
//                    let sessionToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MTczODAxMTIsImp0aSI6IjQ4Njk4NjAwMjIiLCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkiLCJleHAiOjE2ODA0NTIxMTIsInR5cCI6InNlc3Npb25fdG9rZW4iLCJzdDpzY3AiOlswLDgsOSwxNywyM10sInN1YiI6IjVhZThmN2E3OGIwY2NhNGQifQ.KD0a5NaQnVB6Ct3cV1DiCx_ULBmXbxIGZf8EIK6_JT4"
//                    getCookie(sessionToken: sessionToken)
//                }
//            }, receiveValue: { response in
//                promise(.success(response))
//            })
//    }
//    
//    func remote<Request: RequestProtocol>(request: Request) -> Future<Request.ResponseType, APIError> {
//        Future { [self] promise in
//            remote(request: request, promise: promise)
//        }
//    }

    func remote<Request: RequestProtocol>(request: Request) -> Future<Request.ResponseType, APIError> {
        NetworkPublisher.publish(request)
    }

    func generate<Request: APIRequest.IksmSession>(request: Request) -> Future<APIResponse.IksmSession, APIError> {
        NetworkPublisher.generate(request)
    }
}
