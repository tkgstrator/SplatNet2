//
//  File.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Combine
import Foundation
import SplatNet2

public protocol SalmonStatsSessionDelegate: AnyObject {
    var nsaid: String { get set }
    /// 指定されたIDのリザルトを取得してアップロード
    func uploadResult(resultId: Int) -> AnyPublisher<[UploadResult.Response], SP2Error>?
    /// 指定されたIDから最新までのリザルトを取得してアップロード
    func uploadResults(resultId: Int?) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error>?
}
