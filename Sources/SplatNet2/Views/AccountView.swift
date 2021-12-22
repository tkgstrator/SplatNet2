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
