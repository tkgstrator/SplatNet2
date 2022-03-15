//
//  SP2Service.swift
//  SplatNet2Demo
//
//  Created by devonly on 2022/02/05.
//  Copyright © 2022 Magi, Inc. All rights reserved.
//

import CocoaLumberjackSwift
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
    @Published var progress: (current: Int, maximum: Int) = (current: 0, maximum: 0)
    @Published var reminder: (current: Int, total: Int) = (current: 0, total: 0)
    @Published var sp2Error: SP2Error? {
        willSet {
            isPresented = newValue != nil
        }
    }
    @Published var isPresented = false

    init() {
        self.session = SalmonStats(refreshable: true)
        self.account = session.account
        //        self.session.delegate = self
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    DDLogInfo("Success")
                case .failure(let error):
                    DDLogError(error)
                }
            }, receiveValue: { _ in
                //                DDLogInfo(response)
            })
            .store(in: &task)
    }

    func getCoopResult(resultId: Int) {
        session.getCoopResult(resultId: resultId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    DDLogInfo("Success")
                case .failure(let error):
                    DDLogError(error)
                }
            }, receiveValue: { response in
                DDLogInfo(response.jobResult)
            })
            .store(in: &task)
    }

    func getCoopResults(resultId: Int?) {
        session.getCoopResults(resultId: resultId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    DDLogInfo("Success")
                case .failure(let error):
                    DDLogError(error)
                }
            }, receiveValue: { response in
                DDLogInfo(response.count)
            })
            .store(in: &task)
    }

    func getCoopSchedules() {
        DDLogInfo(SplatNet2.schedule.count)
    }

    func getMetadata() {
        session.getMetadata()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    DDLogInfo("Success")
                case .failure(let error):
                    DDLogError(error)
                }
            }, receiveValue: { response in
                DDLogInfo(response)
            })
            .store(in: &task)
    }

    func getCoopResultFromSalmonStats(resultId: Int) {
        session.getCoopResultFromSalmonStats(resultId: resultId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    DDLogInfo("Success")
                case .failure(let error):
                    DDLogError(error)
                }
            }, receiveValue: { response in
                DDLogInfo(response.jobId)
            })
            .store(in: &task)
    }

    func uploadResult(resultId: Int) {
        session.uploadResult(resultId: resultId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    DDLogInfo("Success")
                case .failure(let error):
                    DDLogError(error)
                }
            }, receiveValue: { _ in
            })
            .store(in: &task)
    }

    func uploadResults(resultId: Int? = 2_070) {
        session.uploadResults(resultId: resultId)
    }
}
