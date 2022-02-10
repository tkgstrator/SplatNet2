//
//  SalmonStatsView.swift
//  SplatNet2Demo
//
//  Created by devonly on 2022/02/10.
//  Copyright © 2022 Magi, Inc. All rights reserved.
//

import SalmonStats
import SwiftUI

struct SalmonStatsView: View {
    @EnvironmentObject var service: SP2Service
    @State var isExpanded = true
    @State var isPresented = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded, content: {
            Button(action: {
                isPresented.toggle()
            }, label: {
                Text("SIGN IN")
            })
                .authorize(isPresented: $isPresented, session: service, completion: { result in
                print(result)
            })
            Button(action: {
                service.getPlayerMetadata()
            }, label: { Text("GET METADATA") })
            Button(action: {
            }, label: { Text("GET COOP RESULTS") })
            Button(action: {
            }, label: { Text("GET RESULT") })
            Button(action: {
            }, label: { Text("GET ALL RESULTS") })
            Button(action: {
            }, label: { Text("GET ALL SCHEDULE") })
        }, label: {
            Text("SalmonStats")
        })
    }
}

struct SalmonStatsView_Previews: PreviewProvider {
    static var previews: some View {
        SalmonStatsView()
    }
}
