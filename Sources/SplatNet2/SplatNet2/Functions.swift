//
//  Functions.swift
//  
//
//  Created by tkgstrator on 2021/04/04.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Combine
import Foundation
import KeychainAccess

extension SplatNet2 {
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension URL {
    init(unsafeString: String) {
        // swiftlint:disable:next force_unwrapping
        self.init(string: unsafeString)!
    }
}
