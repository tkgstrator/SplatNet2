//
//  UploadResult.swift
//  SalmonStats
//
//  Created by tkgstrator on 2021/04/17.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation
import SplatNet2

public class UploadResult: RequestType {
    public typealias ResponseType = [UploadResult.Response]

    public var method: HTTPMethod = .post
    public var path: String = "results"
    public var encoding: ParameterEncoding = JSONEncoding.default
    public var parameters: Parameters?
    //  swiftlint:disable:next discouraged_optional_collection
    public var headers: [String: String]?

    init(results: [CoopResult.Response]) {
        self.parameters = ["results": results.map({ $0.asJSON() })]
    }

    init(result: CoopResult.Response) {
        self.parameters = ["results": [result.asJSON()]]
    }

    public struct Response: Codable {
        public var created: Bool
        public var jobId: Int
        public var salmonId: Int
    }
}

extension Encodable {
    func asJSON() -> [String: Any] {
        let encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.outputFormatting = .withoutEscapingSlashes
            return encoder
        }()
        guard let data = try? encoder.encode(self) else {
            return [:]
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return [:]
        }
        return json
    }
}
