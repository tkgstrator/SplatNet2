//
//  URLImage.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/11/17.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import SwiftUI

internal struct URLImage: View {
    @ObservedObject var model: URLImageModel

    init(url: URL) {
        self.model = URLImageModel(url: url)
    }

    var body: some View {
        guard let data = model.image, let image = UIImage(data: data) else {
            return Image(uiImage: UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50, alignment: .center)
                .clipShape(Circle())
        }
        return Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50, alignment: .center)
            .clipShape(Circle())
    }
}
