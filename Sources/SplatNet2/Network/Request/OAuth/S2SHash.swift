//
//  File.swift
//  
//
//  Created by devonly on 2021/07/13.
//

import Foundation
import Alamofire

public class S2SHash: RequestType {
    public var method: HTTPMethod = .post
    public var baseURL = URL(string: "https://elifessler.com/s2s/api/")!
    public var path: String = "gen2"
    public var encoding: ParameterEncoding = URLEncoding.default
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = S2SHash.Response
    
    init(accessToken: String, timestamp: Int, userAgent: String) {
        self.headers = [
            "User-Agent": userAgent
        ]
        self.parameters = [
            "naIdToken": accessToken,
            "timestamp": String(timestamp)
        ]
    }
    
    public struct Response: Codable {
        var hash: String
    }
}
