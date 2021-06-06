import Foundation
import Combine
import Alamofire

struct Publisher {
    typealias APIError = SplatNet2.APIError
    
    static private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static private let queue = DispatchQueue(label: "Network Publisher")
    static private let semaphore = DispatchSemaphore(value: 0)
    
    // IksmSession取得のため
    static func generate<T: IksmSession>(_ request: T) -> Future<Response.IksmSession, SplatNet2.APIError> {
        Future { promise in
            self.queue.async {
                let alamofire = AF.request(request)
                    .validate(statusCode: 200...200)
                    .cURLDescription { request in
//                        print("Request", request)
                    }
                    .responseString { response in
                        semaphore.signal()
                        switch response.result {
                        case .success(let value):
                            do {
                                guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else { throw SplatNet2.APIError.failure }
                                guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: (response.response?.allHeaderFields as! [String: String]), for: (response.response?.url!)!).first?.value else { throw APIError.failure }
                                promise(.success(Response.IksmSession(iksmSession: iksmSession, nsaid: nsaid)))
                            } catch {
                                promise(.failure(SplatNet2.APIError.response))
                            }
                        case .failure:
                            promise(.failure(SplatNet2.APIError.response))
                        }
                    }
                alamofire.resume()
                semaphore.wait()
            }
        }
    }

    // JSON取得のためのPublish
    static func publish<T: RequestType, V: Codable>(_ request: T) -> Future<V, SplatNet2.APIError> {
        Future { promise in
            self.queue.async {
                let alamofire = AF.request(request)
                    .validate(statusCode: 200...200)
                    .validate(contentType: ["application/json"])
                    .cURLDescription { request in
                        #if DEBUG
                        print(request)
                        #endif
                    }
                    .responseJSON { response in
                        semaphore.signal()
                        switch response.result {
                        case .success:
                            do {
                                if let data = response.data {
                                    // JSON受信成功デコード成功
                                    promise(.success(try decoder.decode(V.self, from: data)))
                                } else {
                                    // Data型に変換できない不正なレスポンス
                                    promise(.failure(APIError.response))
                                }
                            } catch {
                                // デコード失敗
                                promise(.failure(APIError.decode))
                            }
                        case .failure:
                            if let statusCode = response.response?.statusCode {
                                switch statusCode {
                                case 400:
                                    promise(.failure(.badrequests))
                                case 401:
                                    promise(.failure(.unauthorized))
                                case 403:
                                    promise(.failure(.forbidden))
                                case 404:
                                    promise(.failure(.unavailable))
                                case 405:
                                    promise(.failure(.method))
                                case 406:
                                    promise(.failure(.acceptable))
                                case 408:
                                    promise(.failure(.timeout))
                                case 426:
                                    promise(.failure(.upgrade))
                                case 429: // Too many requests
                                    promise(.failure(.requests))
                                default:
                                    promise(.failure(APIError.failure))
                                }
                            } else {
                                promise(.failure(APIError.unknown))
                            }
                        }
                    }
                alamofire.resume()
                semaphore.wait()
            }
        }
    }
}

extension String {

    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }

    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return []
        }
        return group.map { group -> String in
            (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
