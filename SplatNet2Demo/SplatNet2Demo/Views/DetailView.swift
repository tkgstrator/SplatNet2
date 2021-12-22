//
//  DetailView.swift
//  SplatNet2Demo
//
//  Created by tkgstrator on 2021/09/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import SplatNet2
import SwiftUI

internal struct DetailView: View {
    @EnvironmentObject var manager: SplatNet2
    @State var signInState: SplatNet2.SignInState?
    @State var currentValue: Int = 0
    @State var maxValue: Int = 0

    var body: some View {
        Form {
            Section(content: {
                HStack(content: {
                    Text("nsaid")
                    Spacer()
                    Text(manager.account?.credential.nsaid ?? "")
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("nickname")
                    Spacer()
                    Text(manager.account?.nickname ?? "")
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("iksm_session")
                    Spacer()
                    Text(manager.account?.credential.iksmSession ?? "")
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("Job num")
                    Spacer()
                    Text("\(manager.account?.coop.jobNum ?? 0)")
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("X-Product Version")
                    Spacer()
                    Text(manager.version)
                        .foregroundColor(.secondary)
                })
            }, header: {
                Text("Account")
            })
            Section(content: {
                Text("\(signInState?.rawValue ?? 0)")
                Text("\(currentValue)/\(maxValue)")
            }, header: {
                Text("Progress")
            })
        }
        .navigationTitle("DetailView")
        .onReceive(NotificationCenter.default.publisher(for: SplatNet2.signIn), perform: { notification in
            guard let state = notification.object as? SplatNet2.SignInState else {
                return
            }
            signInState = state
        })
        .onReceive(NotificationCenter.default.publisher(for: SplatNet2.download), perform: { notification in
            guard let progress = notification.object as? SplatNet2.Progress else {
                return
            }
            maxValue = progress.maxValue
            currentValue = progress.currentValue
        })
    }
}
