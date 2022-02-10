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
import SplatNet2

public final class SP2Service: ObservableObject {
    public private(set) var session: SplatNet2

    @Published public var task: Set<AnyCancellable> = Set<AnyCancellable>()
    @Published var account: UserInfo?

    public var nsaid: String {
        account?.credential.nsaid ?? ""
    }

    internal var nickname: String {
        account?.nickname ?? ""
    }

    internal var iksmSession: String {
        account?.credential.iksmSession ?? ""
    }

    internal var jobNum: Int? {
        account?.coop?.jobNum
    }

    internal var version: String {
        session.version
    }

    init() {
        self.session = SplatNet2()
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
