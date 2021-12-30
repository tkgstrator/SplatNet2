//
//  FailureReason.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public enum FailureReason: String, Codable, CaseIterable {
    case wipeOut = "wipe_out"
    case timeLimit = "time_limit"
}
