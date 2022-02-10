//
//  CoopInfo.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public struct CoopInfo: Codable {
    /// バイト回数
    public var jobNum: Int?
    /// 総金イクラ数
    public var goldenIkuraTotal: Int?
    /// 総赤イクラ数
    public var ikuraTotal: Int?
    /// クマサンポイント
    public var kumaPoint: Int?
    /// 総クマポイント
    public var kumaPointTotal: Int?

    init() {}

    init(from response: Results.Response) {
        self.jobNum = response.summary.card.jobNum
        self.goldenIkuraTotal = response.summary.card.goldenIkuraTotal
        self.ikuraTotal = response.summary.card.ikuraTotal
        self.kumaPoint = response.summary.card.kumaPoint
        self.kumaPointTotal = response.summary.card.kumaPointTotal
    }
}
