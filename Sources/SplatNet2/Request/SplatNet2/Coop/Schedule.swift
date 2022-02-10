//
//  ScheduleCoop.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Common
import Foundation

/// シフトスケジュール
public class Schedule: Codable {
    public struct Response: Codable {
        public var startTime: Int
        public var stageId: StageId
        public var rareWeapon: WeaponType?
        public var endTime: Int
        public var weaponList: [WeaponType]
    }

    public enum StageId: Int, Codable, CaseIterable {
        case shakeup = 5_000
        case shakeship = 5_001
        case shakehouse = 5_002
        case shakelift = 5_003
        case shakeride = 5_004
    }
}
