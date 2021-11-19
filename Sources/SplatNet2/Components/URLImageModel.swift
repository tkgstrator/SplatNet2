//
//  URLImageModel.swift
//  
//
//  Created by tkgstrator on 2021/11/17.
//  
//

import Foundation
import SwiftUI

final class URLImageModel: ObservableObject {
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
