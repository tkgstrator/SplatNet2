//
//  SplatNet2DemoApp.swift
//  SplatNet2Demo
//
//  Created by tkgstrator on 2021/05/01.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Common
import SplatNet2
import SwiftUI

internal class AppDelegate: UIResponder, UIApplicationDelegate {
    //  swiftlint:disable discouraged_optional_collection
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if let manager = LogManager.shared {
            #if DEBUG
            manager.logLevel = .debug
            #else
            manager.logLevel = .info
            #endif
        }
        return true
    }
    //  swiftlint:enable discouraged_optional_collection
}

@main
internal struct SplatNet2DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SP2Service())
        }
    }
}
