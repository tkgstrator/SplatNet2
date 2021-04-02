import Foundation
import Combine
import Alamofire

struct NetworkPublisher {

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static func publish<T: RequestProtocol, V: Decodable>(_ request: T) -> Future<V, APIError> where T.ResponseType == V {
        Future { promise in
            let alamofire = AF.request(request)
                .validate(statusCode: 200...200)
                .validate(contentType: ["application/json"])
                .cURLDescription { request in
                    print(request)
                }
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        do {
                            if let data = response.data {
                                promise(.success(try decoder.decode(V.self, from: data)))
                            }
                            promise(.failure(APIError.response))
                        } catch {
                            print(error)
                            promise(.failure(APIError.decode))
                        }
                    case .failure(let error):
                        print(error)
                        promise(.failure(APIError.failure))
                    }
                }
            alamofire.resume()
        }
    }
}

public enum APIError: Error {
    case failure        // Unacceptable status code/response type
    case json           // Invalid JSON Format
    case response       // Invalid Format
    case decode         // JSONDecoder could not decode
    case requests
    case unavailable
    case upgrade
    case unknown
    case badrequests
}
