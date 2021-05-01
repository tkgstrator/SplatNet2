import Foundation
import Combine

extension SplatNet2 {
    // JSON取得
    func remote<T: RequestType>(request: T) -> Future<T.ResponseType, APIError> {
        return Future { [self] promise in
            remote(request: request, promise: promise)
        }
    }
    
    private func remote<T: RequestType>(request: T, promise: @escaping (Result<T.ResponseType, APIError>) -> ()) {
        Publisher.publish(request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if error == .expired {
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
                    print(error)
                }
            }, receiveValue: { [self] response in
                self.iksmSession = response.iksmSession
                remote(request: request, promise: promise)
            })
            .store(in: &task)
    }
    // IKSM SESSION取得
    func generate<Request: IksmSession>(request: Request) -> Future<Response.IksmSession, APIError> {
//        return Future { [self] promise in
//            remote(request: request, promise: promise)
//        }
        Publisher.generate(request)
    }
}
