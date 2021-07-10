import Foundation
import Combine
import Alamofire

extension SplatNet2 {
    
    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static func generate<T: IksmSession>(_ request: T) -> Future<Response.IksmSession, APIError> {
        return Future { [self] promise in
            dispatchQueue.async {
                let alamofire = AF.request(request)
                    .validate(statusCode: 200...200)
                    .cURLDescription { request in
                    }
                    .responseString { response in
                        semaphore.signal()
                        switch response.result {
                        case .success(let value):
                            do {
                                guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else { throw APIError.invalidResponse(from: value) }
                                guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: (response.response?.allHeaderFields as! [String: String]), for: (response.response?.url!)!).first?.value else { throw APIError.invalidResponse(from: value) }
                                promise(.success(Response.IksmSession(iksmSession: iksmSession, nsaid: nsaid)))
                            } catch(let error as APIError) {
                                promise(.failure(error))
                            } catch {
                                promise(.failure(APIError()))
                            }
                        case .failure(let error):
                            promise(.failure(APIError.invalidResponse(error: error)))
                        }
                    }
                alamofire.resume()
                semaphore.wait()
            }
        }
    }
    
    public static func publish<T: RequestType, V: Codable>(_ request: T) -> Future<V, APIError> {
        return Future { [self] promise in
            dispatchQueue.async {
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
                            if let data = response.data {
                                do {
                                    let response = try decoder.decode(V.self, from: data)
                                    promise(.success(response))
                                } catch {
                                    do {
                                        // 目的のレスポンス形式にデコードできなかった場合
                                        // エラーレスポンスを受け取っている可能性があるので調べる
                                        let statusCode = response.response?.statusCode
                                        var response = try decoder.decode(APIError.self, from: data)
                                        response.statusCode = statusCode
                                        promise(.failure(response))
                                    } catch(let error) {
                                        // エラーレスポンスもデコードできなかった
                                        promise(.failure(APIError.invalidJSON(error: error, from: data)))
                                    }
                                }
                            }
                        case .failure(let error):
                            if let data = response.data {
                                do {
                                    let statusCode = response.response?.statusCode
                                    var response = try decoder.decode(APIError.self, from: data)
                                    response.statusCode = statusCode
                                    promise(.failure(response))
                                } catch(let error) {
                                    promise(.failure(APIError.invalidJSON(error: error, from: data)))
                                }
                            } else {
                                promise(.failure(APIError.invalidResponse(error: error)))
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
