//
//  SwiftUIView.swift
//  
//
//  Created by tkgstrator on 2021/09/13.
//  
//

import SwiftUI
import SplatNet2

struct ProgressLogView: View {
    @State var signInState: SplatNet2.SignInState?
    @State var currentValue: Int = 0
    @State var maxValue: Int = 0
    
    var body: some View {
        Form {
            Text("\(signInState?.rawValue ?? 0)")
            Text("\(currentValue)/\(maxValue)")
        }
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
