import Foundation
import Alamofire

public class APIRequest {
    public class ResultCoop: RequestProtocol {
        var method: HTTPMethod = .get
        var path: String
        var parameters: Parameters?
        var headers: [String: String]?
        typealias ResponseType = APIResponse.ResultCoop

        init(jobId: Int, accessToken: String) {
            self.path = "coop_results/\(jobId)"
            self.headers = ["cookie": "iksm_session=\(accessToken)"]
        }
    }

    public class SessionToken: RequestProtocol {
        var method: HTTPMethod = .post
        var baseURL = URL(string: "https://accounts.nintendo.com")!
        var path: String = "/connect/1.0.0/api/session_token"
        var parameters: Parameters?
        var headers: [String: String]?
        typealias ResponseType = APIResponse.SessionToken

        init(code: String, verifier: String) {
            self.parameters = [
                "client_id": "71b963c1b7b6d119",
                "session_token_code": code,
                "session_token_code_verifier": verifier
            ]
        }
    }

    public class AccessToken: RequestProtocol {
        var method: HTTPMethod = .post
        var baseURL = URL(string: "https://accounts.nintendo.com")!
        var path: String = "/connect/1.0.0/api/token"
        var parameters: Parameters?
        var headers: [String: String]?
        typealias ResponseType = APIResponse.AccessToken

        init(sessionToken: String) {
            self.parameters = [
                "client_id": "71b963c1b7b6d119",
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer-session-token",
                "session_token": sessionToken
            ]
        }
    }

    public class S2SHash: RequestProtocol {
        var method: HTTPMethod = .post
        var baseURL = URL(string: "https://elifessler.com/s2s/api/")!
        var path: String = "gen2"
        var encoding: ParameterEncoding = URLEncoding.default
        var parameters: Parameters?
        var headers: [String: String]?
        typealias ResponseType = APIResponse.S2SHash

        init(accessToken: String, timestamp: Int) {
            self.headers = [
                "User-Agent": "Salmonia/@tkgling"
            ]
            self.parameters = [
                "naIdToken": accessToken,
                "timestamp": String(timestamp)
            ]
        }
    }

    public class FlapgToken: RequestProtocol {
        var method: HTTPMethod = .get
        var baseURL = URL(string: "https://flapg.com")!
        var path: String = "/ika2/api/login"
        var parameters: Parameters?
        var headers: [String: String]?
        typealias ResponseType = APIResponse.FlapgAPI

        init(accessToken: String, timestamp: Int, hash: String, type: Bool) {
            self.headers = [
                "x-token": accessToken,
                "x-time": String(timestamp),
                "x-guid": "037239ef-1914-43dc-815d-178aae7d8934",
                "x-hash": hash,
                "x-ver": "3",
                "x-iid": type ? "app" : "nso"
            ]
        }
    }

    public class SplatoonToken: RequestProtocol {
        var method: HTTPMethod = .post
        var baseURL = URL(string: "https://api-lp1.znc.srv.nintendo.net/")!
        var path: String = "v1/Account/Login"
        var parameters: Parameters?
        var headers: [String: String]?
        typealias ResponseType = APIResponse.SplatoonToken

        init(from result: APIResponse.FlapgAPI, version: String) {
            self.headers = [
                "X-ProductVersion": "\(version)",
                "X-Platform": "Android"
            ]
            self.parameters = [
                "parameter": [
                    "f": result.result.f,
                    "naIdToken": result.result.p1,
                    "timestamp": result.result.p2,
                    "requestId": result.result.p3,
                    "naCountry": "JP",
                    "naBirthday": "1990-01-01",
                    "language": "ja-JP"
                ]
            ]
        }
    }

    public class SplatoonAccessToken: RequestProtocol {
        var method: HTTPMethod = .post
        var baseURL = URL(string: "https://api-lp1.znc.srv.nintendo.net/")!
        var path: String = "v2/Game/GetWebServiceToken"
        var parameters: Parameters?
        var headers: [String: String]?
        typealias ResponseType = APIResponse.SplatoonAccessToken

        init(from result: APIResponse.FlapgAPI, splatoonToken: String, version: String) {
            self.headers = [
                "X-Platform": "Android",
                "Authorization": "Bearer \(splatoonToken)"
            ]
            self.parameters = [
                "parameter": [
                    "f": result.result.f,
                    "id": 5741031244955648,
                    "registrationToken": result.result.p1,
                    "timestamp": result.result.p2,
                    "requestId": result.result.p3
                ]
            ]
        }
    }

    public class IksmSession: RequestProtocol {
        var method: HTTPMethod = .get
        var path: String
        var parameters: Parameters?
        var headers: [String: String]?
        typealias ResponseType = APIResponse.IksmSession

        init(jobId: Int, accessToken: String) {
            self.path = "coop_results/\(jobId)"
            self.headers = ["cookie": "iksm_session=\(accessToken)"]
        }
    }

}
