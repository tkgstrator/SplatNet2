//
//  ContentView.swift
//  SplatNet2Demo
//
//  Created by tkgstrator on 2021/05/01.
//  Copyright © 2021 Magi, Corporation. All rights reserved.

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            MasterView()
            DetailView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
