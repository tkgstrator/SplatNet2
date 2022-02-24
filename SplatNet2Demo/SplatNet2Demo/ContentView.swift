//
//  ContentView.swift
//  SplatNet2Demo
//
//  Created by tkgstrator on 2021/05/01.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import SplatNet2
import SwiftUI

internal struct ContentView: View {
    @EnvironmentObject var service: SP2Service

    var body: some View {
        NavigationView(content: {
            MasterView()
            DetailView()
        })
            .alert(isPresented: $service.isPresented, error: service.sp2Error, actions: { _ in
                Button(action: {}, label: {
                    Text("OK")
                })
            }, message: { error in
                Text(error.failureReason ?? "Unknown error.")
            })
    }
}

internal struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
