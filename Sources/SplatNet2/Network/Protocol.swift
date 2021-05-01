import Foundation
import Alamofire

protocol RequestType: URLRequestConvertible {
    
    associatedtype ResponseType: Decodable
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var baseURL: URL { get }
    var encoding: ParameterEncoding { get }
}

extension RequestType {
    
    var headers: [String: String]? {
        ["User-Agent": "Salmonia/@tkgling"]
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
