//
//  URLImageModel.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/11/17.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI

internal final class URLImageModel: ObservableObject {
    @Published var image: Data?

    init(url: URL) {
        DispatchQueue(label: "URLImage").async {
            let data = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                self.image = data
            }
        }
    }
}
