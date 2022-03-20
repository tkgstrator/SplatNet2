//
//  SalmonStatsSessionDelegate.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation
import KeychainAccess
import SplatNet2

public protocol SalmonStatsSessionDelegate: SplatNet2SessionDelegate {
    /// アップロード済みのリザルトと結果をまとめて返す
    func didFinishLoadResultsFromSplatNet2(results: [SalmonResult])
}
