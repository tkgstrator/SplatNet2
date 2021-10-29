//
//  Notification.swift
//  
//
//  Created by tkgstrator on 2021/09/13.
//  
//

import Foundation

extension SplatNet2 {
    /// ログインの進捗を現す通知
    public static let signIn: Notification.Name = Notification.Name("SPLATNET2_SIGNIN")
    /// ダウンロードの進捗を現す通知
    public static let download: Notification.Name = Notification.Name("SPLATNET2_DOWNLOAD")
    /// アカウントが切り替わったことを現す通知
    public static let account: Notification.Name = Notification.Name("SPLATNET2_ACCOUNT")

    public enum SignInState: Int, CaseIterable {
        case none                   = 0
        case sessiontoken           = 1
        case accesstoken            = 2
        case s2shashnso             = 3
        case flapgnso               = 4
        case splatoontoken          = 5
        case s2shashapp             = 6
        case flapgapp               = 7
        case splatoonaccesstoken    = 8
        case iksmsession            = 9
    }
    
    public struct Progress {
        public let maxValue: Int
        public let currentValue: Int
        
        public init(maxValue: Int, currentValue: Int) {
            self.maxValue = maxValue
            self.currentValue = currentValue
        }
    }
}
