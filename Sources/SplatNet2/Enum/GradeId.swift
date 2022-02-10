//
//  GradeId.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public enum GradeId: String, Codable, CaseIterable {
    case profreshional = "5"
    case overachiver = "4"
    case gogetter = "3"
    case parttimer = "2"
    case apparentice = "1"
    case intern = "0"
}
