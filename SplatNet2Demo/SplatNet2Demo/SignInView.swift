//
//  SignInView.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/09/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Combine
import SplatNet2
import SwiftUI

internal struct SignInView: View {
    @State var task = Set<AnyCancellable>()
    @State var isPresented = false
    @State var environment = false

    var body: some View {
        Form {
            Section(header: Text("OAuth"), content: {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Text("SIGN IN")
                })
                    .authorize(isPresented: $isPresented, manager: manager) { _ in
                    }
                Button(action: {
                    manager.getCoopSummary()
                        .sink(receiveCompletion: { _ in }, receiveValue: { response in
                            print(response)
                        })
                        .store(in: &task)
                }, label: { Text("GET ALL RESULTS") })
                Button(action: { getAllResults(latestJobId: 0) }, label: { Text("GET ALL RESULTS") })
                Button(action: { getNicknameAndIcons() }, label: { Text("GET PLAYER DATA") })
            })
            AccountView(manager: manager)
            Section(header: Text("Content"), content: {
                Button(action: { getAllAccounts() }, label: { Text("GET ALL ACCOUNTS") })
                Button(action: { deleteAllAccounts() }, label: { Text("DELETE ALL ACCOUNTS") })
            })
            Section(header: Text("Auhtorize"), content: {
                Button(action: {
                }, label: { Text("GET ALL ACCOUNTS") })
            })
        }
        .navigationTitle("SplatNet2 Demo")
    }

    private func getAllAccounts() {
//        let accounts = SplatNet2.getAllAccounts()
//        for account in accounts {
//            print(account)
//        }
    }

    private func deleteAllAccounts() {
//        SplatNet2.deleteAllAccounts()
    }

    private func getAllResults(latestJobId: Int) {
//        manager.getResultCoopWithJSON(latestJobId: latestJobId) { completion in
//            switch completion {
//            case .success(let response):
//                print(response)
//            case .failure(let error):
//                print(error)
//            }
//        }
    }

    private func getNicknameAndIcons() {
//        let playerId: [String] = [manager.account.nsaid]
//        manager.getNicknameAndIcons(playerId: playerId) { completion in
//            switch completion {
//            case .success(let response):
//                print(response)
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
}
