import Foundation
import Alamofire

protocol RequestType: URLRequestConvertible {
    
    associatedtype ResponseType: Codable
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var path: String { get }
    var headers: [String: String]? { get set }
    var baseURL: URL { get }
    var encoding: ParameterEncoding { get }
}

extension RequestType {
    
    var headers: [String: String]? {
        if let iksmSession = keychain.getValue(forKey: .iksmSession) {
            return [
                "Cookie": "iksm_session=\(iksmSession)",
                "User-Agent": "Salmonia/@tkgling"
            ]
        } else {
            return [
                "User-Agent": "Salmonia/@tkgling"
            ]
        }
    }

    var encoding: ParameterEncoding {
        JSONEncoding.default
    }
    
    public func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = TimeInterval(5)

        if let params = parameters {
            print(parameters)
            request = try encoding.encode(request, with: params)
        }
        return request
    }
}
