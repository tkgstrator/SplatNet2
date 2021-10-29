//
//  SwiftUIView.swift
//  
//
//  Created by tkgstrator on 2021/09/13.
//  
//

import SwiftUI
import Combine
import SplatNet2

struct SignInView: View {
    @State var task = Set<AnyCancellable>()
    @State var isPresented: Bool = false
    @State var environment: Bool = false
    @State var apiError: APIError?

    var body: some View {
        Form {
            Section() {
                Button(action: {
                    isPresented.toggle()
                }, label: { Text("SIGN IN")})
                .authorize(isPresented: $isPresented) { completion in
                    switch completion {
                    case .success(let value):
                        print(value)
                    case .failure(let error):
                        apiError = error
                    }
                }
                Button(action: { getAllResults(latestJobId: 0) }, label: { Text("GET ALL RESULTS")})
                Button(action: { getNicknameAndIcons() }, label: { Text("GET PLAYER DATA")})
            }
            AccountPicker(manager: manager)
            Section() {
                Button(action: { getAllAccounts() }, label: { Text("GET ALL ACCOUNTS") })
                Button(action: { deleteAllAccounts() }, label: { Text("DELETE ALL ACCOUNTS") })
            }
        }
        .alert(item: $apiError) { error in
            Alert(title: Text("ERROR"), message: Text(error.localizedDescription))
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
        manager.getResultCoopWithJSON(latestJobId: latestJobId) { completion in
            switch completion {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getNicknameAndIcons() {
        let playerId: [String] = [manager.account.nsaid]
        manager.getNicknameAndIcons(playerId: playerId) { completion in
            switch completion {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}
