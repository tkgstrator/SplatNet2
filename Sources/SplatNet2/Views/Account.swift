//
//  AccountPicker.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//

import SwiftUI
import KeychainAccess

public struct AccountView: View {
    private var manager: SplatNet2
    @State var account: UserInfo
    @State var isPresented: Bool = false
    var actionSheet: ActionSheet

    public init(manager: SplatNet2) {
        self.manager = manager
        self._account = State(initialValue: manager.account)
        self.actionSheet = ActionSheet(
            title: Text("ALL_NSO_ACCOUNTS".localized),
            message: Text("SELECT_ACCOUNT".localized),
            buttons: manager.getAllAccounts().map({ account in
                                                    .default(Text(account.nickname), action: {
                                                        manager.account = account
                                                        NotificationCenter.default.post(name: SplatNet2.account, object: account)
                                                        manager.objectWillChange.send()
                                                    })}) + [.cancel()])
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Text("ACCOUNT_CHANGER".localized)
            Spacer()
            Button(action: { isPresented.toggle() }, label: {
                Text(manager.account.nickname)
                    .foregroundColor(.blue)
            })
            .buttonStyle(PlainButtonStyle())
            .actionSheet(isPresented: $isPresented, content: {
                actionSheet
            })
        })
    }
}
