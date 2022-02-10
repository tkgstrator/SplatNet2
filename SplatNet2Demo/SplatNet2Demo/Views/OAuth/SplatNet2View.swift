//
//  OAuthView.swift
//  SplatNet2Demo
//
//  Created by devonly on 2022/02/10.
//  Copyright © 2022 Magi, Inc. All rights reserved.
//

import SplatNet2
import SwiftUI

struct SplatNet2View: View {
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
            .authorize(isPresented: $isPresented, session: service.session, completion: { result in
                print(result)
            })
            Button(action: {
                service.getCoopSummary()
            }, label: { Text("GET COOP RESULTS") })
            Button(action: {
                service.getResult(resultId: 1_000)
            }, label: { Text("GET RESULT") })
            Button(action: {
                service.getResults(resultId: 1_000)
            }, label: { Text("GET ALL RESULTS") })
            Button(action: {
//                DDLogInfo(SplatNet2.schedule)
            }, label: { Text("GET ALL SCHEDULE") })
        }, label: {
            Text("SplatNet2")
        })
    }
}

struct SplatNet2View_Previews: PreviewProvider {
    static var previews: some View {
        SplatNet2View()
    }
}
