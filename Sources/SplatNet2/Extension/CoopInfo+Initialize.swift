//
//  File.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Common
import Foundation

extension CoopInfo {
    init(from response: CoopSummary.Response) {
        self.init(
            jobNum: response.summary.card.jobNum,
            goldenIkuraTotal: response.summary.card.goldenIkuraTotal,
            ikuraTotal: response.summary.card.ikuraTotal,
            kumaPoint: response.summary.card.kumaPoint,
            kumaPointTotal: response.summary.card.kumaPointTotal
        )
    }
}
