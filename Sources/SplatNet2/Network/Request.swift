import Foundation
import Alamofire

public class ResultCoop: RequestType {
    public var baseURL: URL = URL(string: "https://app.splatoon2.nintendo.net/api/")!
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.ResultCoop
    
    init(iksmSession: String?, jobId: Int) {
        self.path = "coop_results/\(jobId)"
        self.headers = ["cookie": "iksm_session=\(iksmSession ?? "")"]
    }
}

public class SummaryCoop: RequestType {
    public var baseURL: URL = URL(string: "https://app.splatoon2.nintendo.net/api/")!
    public var method: HTTPMethod = .get
    public var path: String = "coop_results"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.SummaryCoop
    
    init(iksmSession: String?) {
        self.headers = ["cookie": "iksm_session=\(iksmSession ?? "")"]
    }
}

public class NicknameIcons: RequestType {
    public var baseURL: URL = URL(string: "https://app.splatoon2.nintendo.net/api/")!
    public var method: HTTPMethod = .get
    public var path: String = "nickname_and_icon"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.NicknameIcons
    
    init(iksmSession: String?, playerId: [String]) {
        self.path = "nickname_and_icon?\(playerId.queryString)"
        self.headers = ["cookie": "iksm_session=\(iksmSession ?? "")"]
    }
}

public class SessionToken: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://accounts.nintendo.com/")!
    public var path: String = "connect/1.0.0/api/session_token"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.SessionToken
    
    init(code: String, verifier: String) {
        self.parameters = [
            "client_id": "71b963c1b7b6d119",
            "session_token_code": code,
            "session_token_code_verifier": verifier
        ]
    }
}

public class AccessToken: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://accounts.nintendo.com/")!
    public var path: String = "connect/1.0.0/api/token"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.AccessToken
    
    init(sessionToken: String?) {
        if let sessionToken = sessionToken {
            self.parameters = [
                "client_id": "71b963c1b7b6d119",
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer-session-token",
                "session_token": sessionToken
            ]
        }
    }
}

public class S2SHash: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://elifessler.com/s2s/api/")!
    public var path: String = "gen2"
    public var encoding: ParameterEncoding = URLEncoding.default
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.S2SHash
    
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
    public var method: HTTPMethod = .get
    public var baseURL = URL(string: "https://flapg.com/")!
    public var path: String = "ika2/api/login"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.FlapgAPI
    
    init(accessToken: String, timestamp: Int, hash: String, type: FlapgType) {
        self.headers = [
            "x-token": accessToken,
            "x-time": String(timestamp),
            "x-guid": "037239ef-1914-43dc-815d-178aae7d8934",
            "x-hash": hash,
            "x-ver": "3",
            "x-iid": type.rawValue
        ]
    }
    
    enum FlapgType: String, CaseIterable {
        case app
        case nso
    }
}

public class SplatoonToken: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://api-lp1.znc.srv.nintendo.net/")!
    public var path: String = "v1/Account/Login"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.SplatoonToken
    
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
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://api-lp1.znc.srv.nintendo.net/")!
    public var path: String = "v2/Game/GetWebServiceToken"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.SplatoonAccessToken
    
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
    public var method: HTTPMethod = .get
    public var baseURL = URL(string: "https://app.splatoon2.nintendo.net/")!
    public var path: String = ""
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = Response.IksmSession
    
    init(accessToken: String) {
        self.headers = [
            "Cookie": "iksm_session=",
            "X-GameWebToken": accessToken
        ]
    }
}

private extension Array where Element == String {
    var queryString: String {
        return self.map{ "id=\($0)" }.joined(separator: "&")
    }
}
