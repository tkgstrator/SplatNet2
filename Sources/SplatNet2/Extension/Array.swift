//
//  Array.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/04/04.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public extension Array {
    /// Arrayを指定した件数ごとに分割する
    func chunked(by chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
