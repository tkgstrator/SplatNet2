//
//  SalmonStats.swift
//  SalmonStats
//
//  Created by tkgstrator on 2021/04/10.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//  

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation
import KeychainAccess
import SplatNet2

internal class SalmonStats {}

public extension RequestType {
    var baseURL: URL {
        URL(unsafeString: "https://salmon-stats-api.yuki.games/api/")
    }
}
