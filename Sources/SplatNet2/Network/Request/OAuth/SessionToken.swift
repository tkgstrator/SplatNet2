//
//  SessionToken.swift
//  SplatNet2
//
//  Created by devonly on 2021/07/13.
//

import Foundation
import Alamofire

public class SessionToken: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://accounts.nintendo.com/")!
    public var path: String = "connect/1.0.0/api/session_token"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = SessionToken.Response
    
    init(code: String, verifier: String) {
        self.parameters = [
            "client_id": "71b963c1b7b6d119",
            "session_token_code": code,
            "session_token_code_verifier": verifier
        ]
    }
    
    public struct Response: Codable {
        public var sessionToken: String
    }
}
