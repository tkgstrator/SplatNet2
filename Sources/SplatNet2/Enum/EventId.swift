//
//  EventId.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public enum EventId: Int, Codable, CaseIterable {
    case waterLevels    = 0
    case rush           = 1
    case goldieSeeking  = 2
    case griller        = 3
    case fog            = 4
    case theMothership  = 5
    case cohockCharge   = 6
}
