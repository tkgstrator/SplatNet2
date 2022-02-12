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
    @EnvironmentObject var service: SP2Service

    var body: some View {
        Form {
            Section(content: {
                HStack(content: {
                    Text("nsaid")
                    Spacer()
                    Text(service.nsaid)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("nickname")
                    Spacer()
                    Text(service.nickname)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("iksm_session")
                    Spacer()
                    Text(service.iksmSession.prefix(8))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("api_token")
                    Spacer()
                    Text(service.apiToken.prefix(8))
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                })
                if let jobNum = service.jobNum {
                    HStack(content: {
                        Text("Job num")
                        Spacer()
                        Text("\(jobNum)")
                            .foregroundColor(.secondary)
                    })
                } else {
                    HStack(content: {
                        Text("Job num")
                        Spacer()
                        Text("")
                            .foregroundColor(.secondary)
                    })
                }
                HStack(content: {
                    Text("X-Product Version")
                    Spacer()
                    Text(service.version)
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("Progress")
                    Spacer()
                    Text("\(service.progress.current) -> \(service.progress.maximum)")
                        .foregroundColor(.secondary)
                })
                HStack(content: {
                    Text("Progress")
                    Spacer()
                    Text("\(service.reminder.current) / \(service.reminder.total)")
                        .foregroundColor(.secondary)
                })
            }, header: {
                Text("Account")
            })
        }
        .navigationTitle("DetailView")
    }
}
