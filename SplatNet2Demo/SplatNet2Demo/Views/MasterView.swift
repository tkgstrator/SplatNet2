//
//  MasterView.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/09/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import CocoaLumberjackSwift
import Combine
import SplatNet2
import SwiftUI

internal struct MasterView: View {
    @EnvironmentObject var manager: SplatNet2
    @State var task = Set<AnyCancellable>()
    @State var isPresented = false
    @State var environment = false
    @State var sp2Error: SP2Error?
    @State var allowMoveInList = false

    var SectionSignIn: some View {
        Section(header: Text("OAuth"), content: {
            Button(action: {
                isPresented.toggle()
            }, label: {
                Text("SIGN IN")
            })
            Button(action: {
                manager.getVersion()
                    .sink(receiveCompletion: { _ in }, receiveValue: { response in
                        DDLogInfo(response)
                    })
                    .store(in: &task)
            }, label: { Text("GET X-PRODUCT VERSION") })
            Button(action: {
                manager.getCoopSummary()
                    .sink(receiveCompletion: { completion in
                        switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                DDLogError(error)
                        }
                    }, receiveValue: { _ in
//                        DDLogInfo(response)
                    })
                    .store(in: &task)
            }, label: { Text("GET COOP RESULTS") })
            Button(action: {
                manager.getCoopResult(resultId: 3_590)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                DDLogError(error)
                        }
                    }, receiveValue: { response in
                        DDLogInfo(response)
                    })
                    .store(in: &task)
            }, label: { Text("GET RESULT") })
            Button(action: {
                manager.getCoopResults()
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                    })
                    .store(in: &task)
            }, label: { Text("GET ALL RESULTS") })
            Button(action: {
                DDLogInfo(SplatNet2.schedule)
            }, label: { Text("GET ALL SCHEDULE") })
        })
    }

    var SectionAccount: some View {
        Section(content: {
            NavigationLink(destination: DetailView(), label: {
                Text("ACCOUNT")
            })
            Toggle(isOn: $allowMoveInList, label: {
                Text("ALLOW MOVE IN LIST")
            })
            AccountView(manager: manager)
                .environment(\.allowMoveInList, $allowMoveInList)
        }, header: {
            Text("Account")
        })
    }

    var body: some View {
        Form(content: {
            SectionSignIn
            SectionAccount
        })
            .authorize(isPresented: $isPresented, manager: manager) { completion in
                switch completion {
                    case .success(let value):
                        DDLogInfo(value)
                    case .failure(let error):
                        sp2Error = error
                }
            }
            .navigationTitle("SplatNet2 Demo")
    }
}

extension String {
    static var fakeNsaId: String {
        let randomString: [String] = "0123456789abcdef".map({ String($0) })
        // swiftlint:disable:next force_unwrapping
        return Range(0 ... 15).map({ _ in randomString.randomElement()! }).joined()
    }
}
