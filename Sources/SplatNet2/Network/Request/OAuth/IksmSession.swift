//
//  IksmSession.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//

import Foundation
import Alamofire

public class IksmSession: RequestType {
    public var method: HTTPMethod = .get
    public var baseURL = URL(string: "https://app.splatoon2.nintendo.net/")!
    public var path: String = ""
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = IksmSession.Response
    
    init(accessToken: String) {
        self.headers = [
            "Cookie": "iksm_session=",
            "X-GameWebToken": accessToken
        ]
    }
    
    public struct Response: Codable {
        var iksmSession: String
        var nsaid: String
    }
}
