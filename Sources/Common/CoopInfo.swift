//
//  CoopInfo.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public struct CoopInfo: Codable {
    public init(jobNum: Int, goldenIkuraTotal: Int, ikuraTotal: Int, kumaPoint: Int, kumaPointTotal: Int) {
        self.jobNum = jobNum
        self.goldenIkuraTotal = goldenIkuraTotal
        self.ikuraTotal = ikuraTotal
        self.kumaPoint = kumaPoint
        self.kumaPointTotal = kumaPointTotal
    }

    /// バイト回数
    public var jobNum: Int
    /// 総金イクラ数
    public var goldenIkuraTotal: Int
    /// 総赤イクラ数
    public var ikuraTotal: Int
    /// クマサンポイント
    public var kumaPoint: Int
    /// 総クマポイント
    public var kumaPointTotal: Int
}
