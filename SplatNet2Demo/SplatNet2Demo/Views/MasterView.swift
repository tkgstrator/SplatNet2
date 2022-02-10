//
//  MasterView.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/09/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Combine
import SplatNet2
import SwiftUI

internal struct MasterView: View {
    @EnvironmentObject var service: SP2Service
    @State var isPresented = false

    var SectionSignIn: some View {
        Section(header: Text("OAuth"), content: {
            Button(action: {
                isPresented.toggle()
            }, label: {
                Text("SIGN IN")
            })
            Button(action: {
                service.getVersion()
            }, label: { Text("GET X-PRODUCT VERSION") })
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
        })
    }

    var body: some View {
        Form(content: {
            SplatNet2View()
            SalmonStatsView()
        })
            .authorize(isPresented: $isPresented, session: service.session) { _ in
//                switch completion {
//                    case .success(let value):
//                        DDLogInfo(value)
//                    case .failure(let error):
//                        DDLogError(error.localizedDescription)
//                }
            }
            .navigationTitle("SplatNet2 Demo")
    }
}

extension String {
    static var fakeNsaId: String {
        let randomString: [String] = "0123456789abcdef".map({ String($0) })
        // swiftlint:disable:next force_unwrapping
        return Range(0 ... 15).map({ _ in randomString.randomElement()! }).joined()
    }
}
