//  swiftlint:disable:this file_name
//
//  Functions.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/04/04.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Combine
import Foundation
import KeychainAccess

extension Array {
    /// Arrayを指定した件数ごとに分割する
    func chunked(by chunkSize: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension URL {
    /// 文字列からUnsafeにURLを作成するイニシャライザ
    init(unsafeString: String) {
        // swiftlint:disable:next force_unwrapping
        self.init(string: unsafeString)!
    }
}

public extension String {
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }

    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return []
        }
        return group.map { group -> String in
            (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
