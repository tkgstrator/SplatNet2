//
//  File.swift
//  
//
//  Created by devonly on 2021/12/22.
//

import CocoaLumberjackSwift
import Foundation

public class LogManager: DDLogFileManagerDefault {
    private static let applicationName: String = {
        Bundle.main.bundleIdentifier ?? ProcessInfo.processInfo.processName
    }()

    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    public class var shared: LogManager? {
        self.manager
    }

    public static let manager = LogManager()

    public var logLevel: DDLogLevel {
        get {
            dynamicLogLevel
        }
        set {
            dynamicLogLevel = newValue
        }
    }

    override init(logsDirectory: String?) {
        super.init(logsDirectory: logsDirectory)

        let osLogger = DDOSLogger.sharedInstance
        osLogger.logFormatter = LogFormatter()
        DDLog.add(osLogger, with: .all)
    }
}
