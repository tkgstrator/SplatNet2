//
//  SwiftUIView.swift
//  
//
//  Created by tkgstrator on 2021/09/13.
//  
//

import SwiftUI
import SplatNet2

struct DetailView: View {
    @State var signInState: SplatNet2.SignInState?
    @State var currentValue: Int = 0
    @State var maxValue: Int = 0
    
    var body: some View {
        Form {
            Section(content: {
                HStack(content: {
                    Text("nsaid")
                    Spacer()
                    Text(manager.account.nsaid)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("nickname")
                    Spacer()
                    Text(manager.account.nickname)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("iksm_session")
                    Spacer()
                    Text(manager.account.iksmSession)
                        .lineLimit(1)
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
            guard let state = notification.object as? SplatNet2.SignInState else { return }
            signInState = state
        })
        .onReceive(NotificationCenter.default.publisher(for: SplatNet2.download), perform: { notification in
            guard let progress = notification.object as? SplatNet2.Progress else { return }
            maxValue = progress.maxValue
            currentValue = progress.currentValue
        })
    }
}
