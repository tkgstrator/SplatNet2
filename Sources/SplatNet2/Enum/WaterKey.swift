//
//  WaterKey.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public enum WaterKey: String, Codable, CaseIterable, Identifiable {
    case high
    case low
    case normal
}

public extension WaterKey {
    var id: String { rawValue }
}
