//
//  AccountPicker.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//

import KeychainAccess
import SwiftUI

public struct AccountView: View {
    let manager: SplatNet2
    @State var isPresented: Bool = false

    public init(manager: SplatNet2) {
        self.manager = manager
    }

    public var body: some View {
        NavigationLink(destination: AccountListView(manager: manager), label: {
            Text("ACCOUNT_CHANGER".localized)
        })
            .disabled(manager.accounts.isEmpty)
    }
}

private struct AccountListView: View {
    let manager: SplatNet2
    @State var accounts: [UserInfo] {
        willSet {
        }
        
        didSet {
            // 並び替えが終わったときにその値の先頭のアカウント情報を取る
            guard let account = accounts.first else {
                return
            }
            manager.account = account
            // Keychainの中身を書き換えるのは最後
            try? manager.keychain.setValue(accounts)
        }
    }
    
    init(manager: SplatNet2) {
        self.manager = manager
        self._accounts = State(initialValue: manager.accounts)
    }
    
    var body: some View {
        List(content: {
            ForEach(accounts) { account in
                HStack(content: {
                    URLImage(url: account.imageUri)
                    Spacer()
                    Text(account.nickname)
                })
            }
            .onMove(perform: move)
            .onDelete(perform: delete)
        })
            .toolbar(content: {
                EditButton()
            })
            .onDisappear(perform: sync)
            .onAppear(perform: sync)
            .navigationTitle("ACCOUNTS".localized)
    }
    
    func sync() {
        // 最新のデータを更新
        accounts = manager.accounts
    }
    
    func move(from source: IndexSet, to destination: Int) {
        accounts.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        accounts.remove(atOffsets: offsets)
    }
}
