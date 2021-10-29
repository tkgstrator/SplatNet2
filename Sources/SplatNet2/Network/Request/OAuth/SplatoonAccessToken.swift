//
//  SplatoonAccessToken.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//

import Foundation
import Alamofire

public class SplatoonAccessToken: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://api-lp1.znc.srv.nintendo.net/")!
    public var path: String = "v2/Game/GetWebServiceToken"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = SplatoonAccessToken.Response
    
    init(from result: FlapgToken.Response, splatoonToken: String, version: String) {
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
    
    public struct Response: Codable {
        var correlationId: String
        var result: AccessToken
        var status: Int

        struct AccessToken: Codable {
            var accessToken: String
            var expiresIn: Int
        }
    }
}
