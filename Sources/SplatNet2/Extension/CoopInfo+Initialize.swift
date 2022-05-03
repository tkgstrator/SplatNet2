//
//  CoopInfo+Initialize.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Common
import Foundation

extension CoopInfo {
    init(summary response: CoopSummary.Response) {
        self.init()
        self.jobNum = response.summary.card.jobNum
        self.goldenIkuraTotal = response.summary.card.goldenIkuraTotal
        self.ikuraTotal = response.summary.card.ikuraTotal
        self.kumaPoint = response.summary.card.kumaPoint
        self.kumaPointTotal = response.summary.card.kumaPointTotal
    }
}
