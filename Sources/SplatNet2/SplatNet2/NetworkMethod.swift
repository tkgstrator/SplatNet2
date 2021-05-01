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
                    print(error)
                    promise(.failure(error))
                }
            },
            receiveValue: { response in
                promise(.success(response))
            })
            .store(in: &task)
    }
    
    // IKSM SESSION取得
    func generate<Request: IksmSession>(request: Request) -> Future<Response.IksmSession, APIError> {
        Publisher.generate(request)
    }
}
