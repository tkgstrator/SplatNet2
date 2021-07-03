//
//  SwiftUIView.swift
//  
//
//  Created by devonly on 2021/07/03.
//

import SwiftUI
import KeychainAccess

public struct AccountPicker: View {
    @State var account: UserInfo = SplatNet2().account
    
//    public typealias CompletionHandler = (UserInfo) -> Void
//    let completionHandler: CompletionHandler
//
//    public init(account: UserInfo, completionHandler: @escaping CompletionHandler) {
//        self._account = State(initialValue: account)
//        self.completionHandler = completionHandler
//    }
    public init() {}
    public var body: some View {
        HStack {
            Picker(selection: $account, label: Text("ACCOUNT")) {
                ForEach(Keychain.getAllAccounts()) { account in
                    if !account.nsaid.isEmpty {
                        Text(account.nickname).tag(account)
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            Spacer()
            Text(account.nickname)
                .foregroundColor(.secondary)
        }
    }
}
