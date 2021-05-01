import Foundation
import Alamofire

public class ResultCoop: RequestType {
    var baseURL: URL = URL(string: "https://app.splatoon2.nintendo.net/api/")!
    var method: HTTPMethod = .get
    var path: String
    var parameters: Parameters?
    var headers: [String: String]?
    typealias ResponseType = Response.ResultCoop
    
    init(jobId: Int) {
        self.path = "coop_results/\(jobId)"
        guard let iksmSession = SplatNet2.shared.iksmSession else { return }
        self.headers = ["cookie": "iksm_session=\(iksmSession)"]
    }
}

public class SessionToken: RequestType {
    var method: HTTPMethod = .post
    var baseURL = URL(string: "https://accounts.nintendo.com/")!
    var path: String = "connect/1.0.0/api/session_token"
    var parameters: Parameters?
    var headers: [String: String]?
    typealias ResponseType = Response.SessionToken
    
    init(code: String, verifier: String) {
        self.parameters = [
            "client_id": "71b963c1b7b6d119",
            "session_token_code": code,
            "session_token_code_verifier": verifier
        ]    }
}

public class AccessToken: RequestType {
    var method: HTTPMethod = .post
    var baseURL = URL(string: "https://accounts.nintendo.com/")!
    var path: String = "connect/1.0.0/api/token"
    var parameters: Parameters?
    var headers: [String: String]?
    typealias ResponseType = Response.AccessToken
    
    init() {
        guard let sessionToken = SplatNet2.shared.sessionToken else { return }
        self.parameters = [
            "client_id": "71b963c1b7b6d119",
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer-session-token",
            "session_token": sessionToken
        ]
    }
}

public class S2SHash: RequestType {
    var method: HTTPMethod = .post
    var baseURL = URL(string: "https://elifessler.com/s2s/api/")!
    var path: String = "gen2"
    var encoding: ParameterEncoding = URLEncoding.default
    var parameters: Parameters?
    var headers: [String: String]?
    typealias ResponseType = Response.S2SHash
    
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

public class FlapgToken: RequestType {
    var method: HTTPMethod = .get
    var baseURL = URL(string: "https://flapg.com/")!
    var path: String = "ika2/api/login"
    var parameters: Parameters?
    var headers: [String: String]?
    typealias ResponseType = Response.FlapgAPI
    
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

public class SplatoonToken: RequestType {
    var method: HTTPMethod = .post
    var baseURL = URL(string: "https://api-lp1.znc.srv.nintendo.net/")!
    var path: String = "v1/Account/Login"
    var parameters: Parameters?
    var headers: [String: String]?
    typealias ResponseType = Response.SplatoonToken
    
    init(from result: Response.FlapgAPI, version: String) {
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

public class SplatoonAccessToken: RequestType {
    var method: HTTPMethod = .post
    var baseURL = URL(string: "https://api-lp1.znc.srv.nintendo.net/")!
    var path: String = "v2/Game/GetWebServiceToken"
    var parameters: Parameters?
    var headers: [String: String]?
    typealias ResponseType = Response.SplatoonAccessToken
    
    init(from result: Response.FlapgAPI, splatoonToken: String, version: String) {
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

public class IksmSession: RequestType {
    var method: HTTPMethod = .get
    var baseURL = URL(string: "https://app.splatoon2.nintendo.net/")!
    var path: String = ""
    var parameters: Parameters?
    var headers: [String: String]?
    typealias ResponseType = Response.IksmSession
    
    init(accessToken: String) {
        self.headers = [
            "Cookie": "iksm_session=",
            "X-GameWebToken": accessToken
        ]
    }
}
