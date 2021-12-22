//
//  SplatNet2DemoApp.swift
//  SplatNet2Demo
//
//  Created by tkgstrator on 2021/05/01.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import SplatNet2
import SwiftUI

internal class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        if let manager = LogManager.shared {
            #if DEBUG
            manager.logLevel = .debug
            #else
            manager.logLevel = .info
            #endif
        }
        return true
    }
    // 必要に応じて処理を追加
}

@main
internal struct SplatNet2DemoApp: App {
    //  swiftlint:disable weak_delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SplatNet2(userAgent: "Salmonia3/@tkgling"))
        }
    }
}
