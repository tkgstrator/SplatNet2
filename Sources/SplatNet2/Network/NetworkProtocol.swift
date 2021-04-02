import Foundation
import Alamofire

protocol APIProtocol {
    associatedtype ResponseType: Decodable

    var method: HTTPMethod { get }
    var baseURL: URL { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var allowConstrainedNetworkAccess: Bool { get }

}

extension APIProtocol {
    var baseURL: URL {
        URL(string: "https://app.splatoon2.nintendo.net/api/")!
    }

    var headers: [String: String]? {
        ["User-Agent": "Salmonia/@tkgling"]
    }

    var allowConstrainedNetworkAccess: Bool {
        true
    }
}

protocol RequestProtocol: APIProtocol, URLRequestConvertible {
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

extension RequestProtocol {
    var encoding: ParameterEncoding {
        JSONEncoding.default
    }

    public func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = TimeInterval(5)
        request.allowsConstrainedNetworkAccess = allowConstrainedNetworkAccess

        if let params = parameters {
            print(parameters)
            request = try encoding.encode(request, with: params)
        }
        return request
    }
}
