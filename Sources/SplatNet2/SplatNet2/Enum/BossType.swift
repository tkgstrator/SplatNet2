//
//  BossType.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import CodableDictionary
import Foundation

public enum BossType: String, Codable, CaseIterable, CodableDictionaryKey {
    case goldie = "3"
    case steelhead = "6"
    case flyfish = "9"
    case scrapper = "12"
    case steelEel = "13"
    case stinger = "14"
    case maws = "15"
    case griller = "16"
    case drizzler = "21"
}
