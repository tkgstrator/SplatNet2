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

    public class AccessToken: RequestProtocol {
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

    public class S2SHash: RequestProtocol {
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

    public class FlapgToken: RequestProtocol {
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

    public class SplatoonToken: RequestProtocol {
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

    public class SplatoonAccessToken: RequestProtocol {
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

    public class IksmSession: RequestProtocol {
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

}
