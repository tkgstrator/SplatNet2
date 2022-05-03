//
//  SP2Service+SplatNet2SessionDelegate.swift
//  SplatNet2Demo
//
//  Created by Shota Morimoto on 2022/02/07.
//  Copyright © 2022 Magi, Inc. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation
import SplatNet2

extension SP2Service: SplatNet2SessionDelegate {
    public func isGettingResultId(current: Int) {
        DDLogInfo("Getting results: \(current)")
        DispatchQueue.main.async(execute: {
            self.progress.current = current
            self.reminder.current = self.reminder.total - (self.progress.maximum - current)
        })
    }

    public func didFinishSplatNet2SignIn(account: UserInfo) {
        DispatchQueue.main.async(execute: {
            DDLogInfo(account)
            self.account = account
        })
    }

    public func willRunningSplatNet2SignIn() {
    }

    public func failedWithSP2Error(error: SP2Error) {
        DispatchQueue.main.async(execute: {
            self.sp2Error = error
        })
    }

    public func willReceiveSubscription(subscribe: Subscription) {
    }

    public func willReceiveOutput(output: Decodable & Encodable) {
    }

    public func willReceiveCompletion(completion: Subscribers.Completion<AFError>) {
    }

    public func willReceiveCancel() {
    }

    public func willReceiveRequest(request: Subscribers.Demand) {
    }

    public func progressSignIn(state: SignInState) {
    }

    public func isAvailableResults(current: Int, maximum: Int) {
        DDLogInfo("Getting results: \(current) -> \(maximum)")
        DispatchQueue.main.async(execute: {
            self.progress = (current: current, maximum: maximum)
            self.reminder = (current: 0, total: maximum - current + 1)
        })
    }

    public func failedWithUnavailableVersion(version: String) {
        DDLogError("XProductVersion \(version) is no longer available.")
    }
}
