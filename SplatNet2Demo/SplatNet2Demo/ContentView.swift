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
            .alert(item: $service.sp2Error, content: { error in
                Alert(title: Text("Error \(String(format: "%04d", error.errorCode))"), message: Text(error.localizedDescription), dismissButton: .default(Text("Dismiss")))
            })
    }
}

internal struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
