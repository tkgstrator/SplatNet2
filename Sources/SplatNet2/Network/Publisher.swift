import Foundation
import Combine
import Alamofire

struct Publisher {

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static let queue = DispatchQueue(label: "Network Publisher")
    static let semaphore = DispatchSemaphore(value: 0)
    
    // IksmSession取得のため
    static func generate<T: IksmSession>(_ request: T) -> Future<Response.IksmSession, APIError> {
        Future { promise in
            self.queue.async {
                let alamofire = AF.request(request)
                    .validate(statusCode: 200...200)
                    .cURLDescription { request in
                        print("Request", request)
                    }
                    .responseString { response in
                        switch response.result {
                        case .success(let value):
                            do {
                                guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else { throw APIError.failure }
                                guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: (response.response?.allHeaderFields as [String: String]), for: (response.response?.url!)!).first?.value else { throw APIError.failure }
                                promise(.success(Response.IksmSession(iksmSession: iksmSession, nsaid: nsaid)))
                            } catch {
                                promise(.failure(APIError.response))
                            }
                        case .failure(let error):
                            promise(.failure(APIError.response))
                        }
                    }
                alamofire.resume()
            }
        }
    }

    // JSON取得のためのPublish
    static func publish<T: RequestType, V: Codable>(_ request: T) -> Future<V, APIError> {
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
                                    promise(.success(try decoder.decode(V.self, from: data)))
                                } else {
                                    promise(.failure(APIError.response))
                                }
                            } catch {
                                print(error)
                                promise(.failure(APIError.decode))
                            }
                        case .failure(let error):
                            if let statusCode = response.response?.statusCode {
                                print("STATUS CODE", statusCode)
                                switch statusCode {
                                case 403:
                                    // セッション有効切れ
                                    promise(.failure(APIError.expired))
                                case 429:
                                    // S2S APIのリクエスト過多
                                    promise(.failure(APIError.requests))
                                default:
                                    break
                                }
                                do {
                                    if let data = response.data {
                                        let data = try decoder.decode(Response.ErrorData.self, from: data)
                                        promise(.failure(APIError.failure))
                                    }
                                } catch {
                                    promise(.failure(APIError.decode))
                                }
                            } else {
                                promise(.failure(APIError.fatal))
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

public enum APIError: Error {
    case failure        // Unacceptable status code/response type
    case json           // Invalid JSON Format
    case response       // Invalid Format
    case decode         // JSONDecoder could not decode
    case requests       //
    case unavailable    // Server is unavailable
    case upgrade        // X-Product Version needs to upgrade
    case unknown
    case badrequests    // Bad request
    case fatal          // fatal error
    case grant          // Invalid GrantType for AccessToken
    case s2shash        // Too many request
    case expired        // Expired IksmSession
    case empty          // Empty iksmSession, sessionToken
}
