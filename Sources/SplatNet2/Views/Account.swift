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
            destination: AccountListView()
                .environment(\.allowMoveInList, allowMoveInList)
                .environmentObject(manager),
            label: {
                Text("ACCOUNT_CHANGER".localized)
            }
        )
    }
}

private struct AccountListView: View {
    @EnvironmentObject var manager: SplatNet2
    @Environment(\.allowMoveInList) var allowMoveInList

    var body: some View {
        if allowMoveInList.wrappedValue {
            List(content: {
                ForEach(manager.accounts) { account in
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
//                .onDisappear(perform: sync)
//                .onAppear(perform: sync)
                .navigationTitle("ACCOUNTS".localized)
        } else {
            List(content: {
                ForEach(manager.accounts) { account in
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
//                .onDisappear(perform: sync)
//                .onAppear(perform: sync)
                .navigationTitle("ACCOUNTS".localized)
        }
    }

    func sync() {
        // 最新のデータを更新
//        accounts = manager.accounts
    }

    func move(from source: IndexSet, to destination: Int) {
        manager.accounts.move(fromOffsets: source, toOffset: destination)
    }

    func delete(at offsets: IndexSet) {
        print(manager.accounts.count)
        manager.accounts.remove(atOffsets: offsets)
        print(manager.accounts.count)
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
