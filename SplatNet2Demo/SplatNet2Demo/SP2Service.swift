//
//  SP2Service.swift
//  SplatNet2Demo
//
//  Created by devonly on 2022/02/05.
//  Copyright © 2022 Magi, Inc. All rights reserved.
//

import Combine
import Common
import Foundation
import SalmonStats
import SplatNet2

public final class SP2Service: ObservableObject {
    public private(set) var session: SalmonStats

    @Published public var task: Set<AnyCancellable> = Set<AnyCancellable>()
    @Published var account: UserInfo? {
        willSet {
            guard let account = newValue else {
                return
            }

            self.nsaid = account.credential.nsaid
            self.nickname = account.nickname
            self.iksmSession = account.credential.iksmSession
            self.version = session.version
            if let apiToken = session.apiToken {
                self.apiToken = apiToken
            }

            if let jobNum = account.coop?.jobNum {
                self.jobNum = String(describing: jobNum)
            } else {
                self.jobNum = "-"
            }
        }
    }

    @Published var nsaid: String = ""
    @Published var nickname: String = ""
    @Published var iksmSession: String = ""
    @Published var jobNum: String = ""
    @Published var apiToken: String = ""
    @Published var version: String = ""

    init() {
        self.session = SalmonStats()
        self.account = session.account
        self.session.delegate = self
    }

    func getVersion() {
        session.getVersion()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                print(response)
            })
            .store(in: &task)
    }

    func getCoopSummary() {
        session.getCoopSummary()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                print(response)
            })
            .store(in: &task)
    }

    func getResult(resultId: Int) {
        session.getCoopResult(resultId: resultId)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                print(response)
            })
            .store(in: &task)
    }

    func getResults(resultId: Int) {
        session.getCoopSummary(resultId: resultId)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { response in
                print(response)
            })
            .store(in: &task)
    }
}
