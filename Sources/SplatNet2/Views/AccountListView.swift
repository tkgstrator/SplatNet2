//
//  AccountListView.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/12/21.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI

internal struct AccountListView: View {
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
                .navigationTitle("ACCOUNTS".localized)
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        manager.accounts.move(fromOffsets: source, toOffset: destination)
    }

    func delete(at offsets: IndexSet) {
        manager.accounts.remove(atOffsets: offsets)
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
