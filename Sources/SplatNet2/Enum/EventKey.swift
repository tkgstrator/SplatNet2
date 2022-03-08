//
//  EventType.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public enum EventKey: String, Codable, CaseIterable {
    case waterLevels    = "water-levels"
    case rush           = "rush"
    case goldieSeeking  = "goldie-seeking"
    case griller        = "griller"
    case fog            = "fog"
    case theMothership  = "the-mothership"
    case cohockCharge   = "cohock-charge"
}
