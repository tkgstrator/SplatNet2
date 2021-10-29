//
//  Publisher.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//

import Foundation
import Combine
import Alamofire

extension SplatNet2 {
    
    static func generate<T: IksmSession>(_ request: T) -> Future<IksmSession.Response, APIError> {
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
                                    guard let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1) else { throw APIError.response }
                                    guard let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: (response.response?.allHeaderFields as! [String: String]), for: (response.response?.url!)!).first?.value else { throw APIError.response }
                                    promise(.success(IksmSession.Response(iksmSession: iksmSession, nsaid: nsaid)))
                                } catch(let error as APIError) {
                                    promise(.failure(error))
                                } catch {
                                    promise(.failure(.unavailable))
                                }
                            case .failure:
                                promise(.failure(.response))
                        }
                    }
                alamofire.resume()
                semaphore.wait()
            }
        }
    }
    
    public func publish<T: RequestType, V: Codable>(_ request: T) -> Future<V, APIError> {
        return Future { [self] promise in
            let alamofire = AF.request(request)
                .validate(statusCode: 200...200)
                .validate(contentType: ["application/json"])
                .cURLDescription { request in
                    //                        print(request)
                }
                .responseJSON { response in
                    switch response.result {
                        case .success:
                            if let data = response.data {
                                do {
                                    let response = try decoder.decode(V.self, from: data)
                                    promise(.success(response))
                                } catch(let error) {
                                    print("DECODE ERROR", error)
                                    // ステータスコードが200でもエラーが発生している場合はある
                                    do {
                                        let response = try decoder.decode(APIError.Response.self, from: data)
                                        switch response.statusCode {
                                            case 9400:
                                                promise(.failure(.badrequest))
                                            case 9403:
                                                promise(.failure(.forbidden))
                                            case 9404:
                                                promise(.failure(.notfound))
                                            case 9406:
                                                promise(.failure(.unauthorized))
                                            case 9427:
                                                promise(.failure(.upgrade))
                                            default:
                                                promise(.failure(.undecodable))
                                        }
                                    } catch {
                                        promise(.failure(.undecodable))
                                    }
                                }
                            }
                        case .failure:
                            switch response.response?.statusCode {
                                case 400:
                                    promise(.failure(.badrequest))
                                case 401:
                                    promise(.failure(.unauthorized))
                                case 403:
                                    promise(.failure(.forbidden))
                                case 404:
                                    promise(.failure(.notfound))
                                case 405:
                                    promise(.failure(.notallowed))
                                case 406:
                                    promise(.failure(.unacceptable))
                                case 408:
                                    promise(.failure(.timeout))
                                case 426:
                                    promise(.failure(.upgrade))
                                case 429:
                                    promise(.failure(.manyrequests))
                                case 432:
                                    promise(.failure(.response))
                                case 433:
                                    promise(.failure(.unavailable))
                                default:
                                    promise(.failure(.fatalerror))
                            }
                    }
                }
            alamofire.resume()
        }
    }
}

public extension String {
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
