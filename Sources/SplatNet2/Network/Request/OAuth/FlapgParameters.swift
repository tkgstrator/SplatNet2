//
//  File.swift
//  
//
//  Created by devonly on 2021/07/13.
//

import Foundation
import Alamofire

public class FlapgToken: RequestType {
    public var method: HTTPMethod = .get
    public var baseURL = URL(string: "https://flapg.com/")!
    public var path: String = "ika2/api/login"
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = FlapgToken.Response
    
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
    
    public struct Response: Codable {
        var result: FlapgParameters

        struct FlapgParameters: Codable {
            var f: String
            var p1: String
            var p2: String
            var p3: String
        }
    }
}
