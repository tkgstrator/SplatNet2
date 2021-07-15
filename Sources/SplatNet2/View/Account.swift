//
//  AccountPicker.swift
//  SplatNet2
//
//  Created by devonly on 2021/07/03.
//

import SwiftUI
import KeychainAccess

public struct AccountPicker: View {
    @State var account: UserInfo = SplatNet2.account
    
    public init() {}
    public var body: some View {
        Picker(selection: $account, label: Text(account.nickname)) {
            ForEach(SplatNet2.getAllAccounts()) { account in
                Text(account.nickname)
                    .tag(account)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: account) { newValue in
        }
    }
}
