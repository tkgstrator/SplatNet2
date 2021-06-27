import Foundation
import Combine
import Alamofire

extension SplatNet2 {
    
    static private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static private let queue = DispatchQueue(label: "Network Publisher")
    static private let semaphore = DispatchSemaphore(value: 0)
    
    // IksmSession取得のため
    static func generate<T: IksmSession>(_ request: T) -> Future<Response.IksmSession, Error> {
        Future { promise in
            self.queue.async {
                let alamofire = AF.request(request)
                    .validate(statusCode: 200...200)
                    .cURLDescription { request in
                        #if DEBUG
                        print("Request", request)
                        #endif
                    }
                    .responseString { response in
                        switch response.result {
                        case .success(let value):
                            do {
                                guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else { throw SplatNet2.APIError.failure }
                                guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: (response.response?.allHeaderFields as! [String: String]), for: (response.response?.url!)!).first?.value else { throw APIError.failure }
                                promise(.success(Response.IksmSession(iksmSession: iksmSession, nsaid: nsaid)))
                            } catch {
                                promise(.failure(APIError.response))
                            }
                        case .failure:
                            promise(.failure(APIError.response))
                        }
                    }
                alamofire.resume()
            }
        }
    }
    
    // JSON取得のためのPublish
    static func publish<T: RequestType, V: Codable>(_ request: T) -> Future<V, Error> {
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
                        switch response.result {
                        case .success:
                            if let data = response.data {
                                do {
                                    promise(.success(try decoder.decode(V.self, from: data)))
                                } catch {
                                    // 目的のレスポンス形式にデコードできなかった場合
                                    do {
                                        // エラーレスポンスを受け取っている可能性があるので調べる
                                        let response = try decoder.decode(Response.ServerError.self, from: data)
                                        promise(.failure(response))
                                    } catch {
                                        // エラーレスポンスもできなかった
                                        promise(.failure(APIError.decode))
                                    }
                                }
                            } else {
                                // レスポンスにBodyが含まれていなかった
                                promise(.failure(APIError.response))
                            }
                        case .failure(let error):
                            if let data = response.data {
                                do {
                                    if let statusCode = response.response?.statusCode {
                                        var response = try decoder.decode(Response.ServerError.self, from: data)
                                        response.status = statusCode
                                        promise(.failure(response))
                                    } else {
                                        promise(.failure(APIError.decode))
                                    }
                                } catch {
                                    promise(.failure(APIError.response))
                                }
                            } else {
                                
                            }
                        }
                    }
                alamofire.resume()
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
