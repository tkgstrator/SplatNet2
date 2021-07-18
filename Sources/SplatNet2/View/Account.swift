//
//  AccountPicker.swift
//  SplatNet2
//
//  Created by devonly on 2021/07/03.
//

import SwiftUI
import KeychainAccess

public struct AccountPicker: View {
    private var manager: SplatNet2
    @State var account: UserInfo
    
    public init(manager: SplatNet2) {
        self.manager = manager
        self._account = State(initialValue: manager.account)
    }
    
    public var body: some View {
        HStack {
            Picker(selection: $account, label: Text("ACCOUNT_CHANGER".localized)) {
                ForEach(manager.getAllAccounts()) { account in
                    Text(account.nickname)
                        .tag(account)
                }
            }
            Spacer()
            Text(account.nickname)
                .foregroundColor(.secondary)
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: account) { newValue in
            manager.account = newValue
        }
    }
}
