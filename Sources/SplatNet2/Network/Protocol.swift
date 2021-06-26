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
    
    var encoding: ParameterEncoding {
        JSONEncoding.default
    }
    
    public func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding!)!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = TimeInterval(5)

        if let params = parameters {
            request = try encoding.encode(request, with: params)
        }
        return request
    }
}
