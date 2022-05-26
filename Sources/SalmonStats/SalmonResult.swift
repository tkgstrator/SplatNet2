//
//  SalmonResult.swift
//  
//
//  Created by devonly on 2022/03/14.
//

import Foundation
import SplatNet2

public struct SalmonResult: Codable {
    public let id: Int
    public let result: CoopResult.Response
    public let status: UploadStatus

    public enum UploadStatus: Int, Codable, CaseIterable {
        case failure
        case success
    }

    init(result: CoopResult.Response) {
        self.id = 0
        self.status = .failure
        self.result = result
    }

    init(result: (UploadResult.Response, CoopResult.Response)) {
        self.id = result.0.salmonId
        self.status = result.0.created ? .success : .failure
        self.result = result.1
    }
}
