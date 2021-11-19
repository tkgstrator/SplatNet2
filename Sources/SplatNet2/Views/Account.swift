//
//  AccountView.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import KeychainAccess
import SwiftUI

public struct AccountView: View {
    @Environment(\.allowMoveInList) var allowMoveInList
    let manager: SplatNet2

    public init(manager: SplatNet2) {
        self.manager = manager
    }

    public var body: some View {
        NavigationLink(
            destination: AccountListView(manager: manager).environment(\.allowMoveInList, allowMoveInList),
            label: {
                Text("ACCOUNT_CHANGER".localized)
            }
        )
    }
}

private struct AccountListView: View {
    @Environment(\.allowMoveInList) var allowMoveInList
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
    let manager: SplatNet2

    init(manager: SplatNet2) {
        self.manager = manager
        self._accounts = State(initialValue: manager.accounts)
    }

    var body: some View {
        if allowMoveInList.wrappedValue {
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
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        EditButton()
                    })
                    ToolbarItem(placement: .navigationBarLeading, content: {
                        AddButton(manager: manager)
                    })
                })
                .onDisappear(perform: sync)
                .onAppear(perform: sync)
                .navigationTitle("ACCOUNTS".localized)
        } else {
            List(content: {
                ForEach(accounts) { account in
                    HStack(content: {
                        URLImage(url: account.imageUri)
                        Spacer()
                        Text(account.nickname)
                    })
                }
                .onDelete(perform: delete)
            })
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        EditButton()
                    })
                    ToolbarItem(placement: .navigationBarLeading, content: {
                        AddButton(manager: manager)
                    })
                })
                .onDisappear(perform: sync)
                .onAppear(perform: sync)
                .navigationTitle("ACCOUNTS".localized)
        }
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

private struct AddButton: View {
    let manager: SplatNet2
    @State var isPresented = false

    var body: some View {
        Button(action: {
            isPresented.toggle()
        }, label: {
            Image(systemName: "plus.circle")
        })
            .authorize(isPresented: $isPresented, manager: manager, completion: { _ in
            })
    }
}

public struct AllowMoveInList: EnvironmentKey {
    public typealias Value = Binding<Bool>

    public static var defaultValue: Binding<Bool> = .constant(false)
}

public extension EnvironmentValues {
    var allowMoveInList: Binding<Bool> {
        get {
            self[AllowMoveInList.self]
        }
        set {
            self[AllowMoveInList.self] = newValue
        }
    }
}
