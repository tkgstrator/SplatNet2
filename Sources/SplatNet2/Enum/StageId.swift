//
//  StageId.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public enum StageId: Int, Codable, CaseIterable, Identifiable {
    case shakeup    = 5_000
    case shakeship  = 5_001
    case shakehouse = 5_002
    case shakelift  = 5_003
    case shakeride  = 5_004
}

public extension StageId {
    var id: Int { rawValue }
}
