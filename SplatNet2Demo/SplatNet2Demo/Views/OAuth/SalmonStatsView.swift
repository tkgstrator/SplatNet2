//
//  SalmonStatsView.swift
//  SplatNet2Demo
//
//  Created by devonly on 2022/02/10.
//  Copyright © 2022 Magi, Inc. All rights reserved.
//

import CocoaLumberjackSwift
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
                .authorizeToken(isPresented: $isPresented, session: service.session)
            Button(action: {
                service.getMetadata()
            }, label: { Text("GET METADATA") })
            Button(action: {
                service.uploadResult(resultId: 2_030)
            }, label: { Text("UPLOAD RESULT") })
            Button(action: {
                service.uploadResults()
            }, label: { Text("UPLOAD ALL RESULTS") })
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
