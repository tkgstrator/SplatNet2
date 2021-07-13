//
//  SwiftUIView.swift
//  
//
//  Created by devonly on 2021/07/03.
//

import SwiftUI
import KeychainAccess

public struct AccountPicker: View {
    @State var account: UserInfo = Keychain.account
    
    public init() {}
    public var body: some View {
        HStack {
            Picker("ACCOUNT_CHANGER".localized, selection: $account) {
                ForEach(Keychain.getAllAccounts()) { account in
                    Text(account.nickname).tag(account)
                }
            }
            .pickerStyle(MenuPickerStyle())
            Spacer()
            Text(account.nickname)
                .foregroundColor(.secondary)
        }
        .onChange(of: account) { account in
            Keychain.activeId = account.nsaid
        }
    }
}
