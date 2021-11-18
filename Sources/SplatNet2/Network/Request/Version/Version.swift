//
//  File.swift
//  
//
//  Created by tkgstrator on 2021/11/15.
//  
//

import Foundation
import Alamofire

public class XVersion: RequestType {
    public var baseURL: URL = URL(string: "https://itunes.apple.com/")!
    public var method: HTTPMethod = .get
    public var path: String
    public var parameters: Parameters?
    public var headers: [String: String]?
    public typealias ResponseType = XVersion.Response
    
    init() {
        self.path = "lookup?id=1234806557"
    }
    
    // MARK: - Response
    public struct Response: Codable {
        let resultCount: Int
        public let results: [Information]
    }

    // MARK: - ResultElement
    public struct Information: Codable {
        public let minimumOsVersion: String
        public let version: String
        public let currentVersionReleaseDate: String
    }
}
