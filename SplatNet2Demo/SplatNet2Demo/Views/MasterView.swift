//
//  MasterView.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/09/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Combine
import SplatNet2
import SwiftUI

internal struct MasterView: View {
    @State var task = Set<AnyCancellable>()
    @State var isPresented = false
    @State var environment = false
    @State var sp2Error: SP2Error?
    @State var allowMoveInList = false

    var body: some View {
        Form {
            Section(header: Text("OAuth"), content: {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Text("SIGN IN")
                })
                    .authorize(isPresented: $isPresented, manager: manager) { completion in
                    switch completion {
                    case .success(let value):
                        print(value)
                    case .failure(let error):
                        sp2Error = error
                    }
                    }
                Button(action: {
                    manager.getVersion()
                        .sink(receiveCompletion: { _ in }, receiveValue: { response in
                            print(response)
                        })
                        .store(in: &task)
                }, label: { Text("GET X-PRODUCT VERSION") })
                Button(action: {
                    manager.getCoopSummary(resultId: 3_500)
                        .sink(receiveCompletion: { completion in
                            print(completion)
                        }, receiveValue: { response in
                            print(response)
                        })
                        .store(in: &task)
                }, label: { Text("GET COOP RESULTS") })
                Button(action: {
                    manager.getCoopResult(resultId: 3_590)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            print(completion)
                        }, receiveValue: { response in
                            print(response)
                        })
                        .store(in: &task)
                }, label: { Text("GET RESULT") })
                Button(action: {
                    manager.getCoopResults(resultId: 3_580)
                        .sink(receiveCompletion: { _ in }, receiveValue: { response in
                            print(response)
                        })
                        .store(in: &task)
                }, label: { Text("GET ALL RESULTS") })
                Button(action: {
                    print(SplatNet2.schedule)
                }, label: { Text("GET ALL SCHEDULE") })
            })
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
            Section(header: Text("Content"), content: {
                Button(action: {
                    manager.addDummyAccount()
                }, label: { Text("ADD DUMMY ACCOUNT") })
            })
            Section(header: Text("Auhtorize"), content: {
                Button(action: {
                }, label: { Text("GET ALL ACCOUNTS") })
            })
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
