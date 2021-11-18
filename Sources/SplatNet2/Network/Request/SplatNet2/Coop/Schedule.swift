//
//  ScheduleCoop.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

public class Schedule: Codable {
    public struct Response: Codable {
        public var startTime: Int
        public var stageId: Int
        public var rareWeapon: Int
        public var endTime: Int
        public var weaponList: [Int]
    }
}
