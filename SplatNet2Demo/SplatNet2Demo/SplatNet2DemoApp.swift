//
//  SplatNet2DemoApp.swift
//  SplatNet2Demo
//
//  Created by tkgstrator on 2021/05/01.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import SplatNet2
import SwiftUI

public let manager = SplatNet2(version: "1.13.1")

@main
internal struct SplatNet2DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
