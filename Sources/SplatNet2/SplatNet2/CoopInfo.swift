//
//  CoopInfo.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public class CoopInfo: Codable {
    /// バイト回数
    public var jobNum: Int = 0
    /// 総金イクラ数
    public var goldenIkuraTotal: Int = 0
    /// 総赤イクラ数
    public var ikuraTotal: Int = 0
    /// クマサンポイント
    public var kumaPoint: Int = 0
    /// 総クマポイント
    public var kumaPointTotal: Int = 0

    init() {}

    init(from response: Results.Response) {
        self.jobNum = response.summary.card.jobNum
        self.goldenIkuraTotal = response.summary.card.goldenIkuraTotal
        self.ikuraTotal = response.summary.card.ikuraTotal
        self.kumaPoint = response.summary.card.kumaPoint
        self.kumaPointTotal = response.summary.card.kumaPointTotal
    }
}
