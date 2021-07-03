//
//  SwiftUIView.swift
//  
//
//  Created by devonly on 2021/07/03.
//

import SwiftUI

public struct AccountPicker: View {
    @State var account: UserInfo
    
    public typealias CompletionHandler = (UserInfo) -> Void
    let completionHandler: CompletionHandler
    
    public init(account: UserInfo, completionHandler: @escaping CompletionHandler) {
        self._account = State(initialValue: account)
        self.completionHandler = completionHandler
    }

    public var body: some View {
        HStack {
            Picker(selection: $account, label: Text("ACCOUNT")) {
                ForEach(SplatNet2.getAllAccounts()) { account in
                    Text(account.nickname).tag(account)
                }
            }
            .pickerStyle(MenuPickerStyle())
            Spacer()
            Text(account.nickname)
                .foregroundColor(.secondary)
        }
        .onChange(of: account) { value in
            completionHandler(value)
        }
    }
}
