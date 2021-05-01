//
//  ContentView.swift
//  SplatNet2Demo
//
//  Created by devonly on 2021/05/01.
//

import SwiftUI
import SplatNet2
import Combine

struct ContentView: View {
    @State var task = Set<AnyCancellable>()
    
    let iksmSession: String = "4adb16c6a4bbbdd59e74602546e8ba235bde90fb"
    let sessionToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MTczODAxMTIsImp0aSI6IjQ4Njk4NjAwMjIiLCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkiLCJleHAiOjE2ODA0NTIxMTIsInR5cCI6InNlc3Npb25fdG9rZW4iLCJzdDpzY3AiOlswLDgsOSwxNywyM10sInN1YiI6IjVhZThmN2E3OGIwY2NhNGQifQ.KD0a5NaQnVB6Ct3cV1DiCx_ULBmXbxIGZf8EIK6_JT4"
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                SplatNet2.shared.configure(sessionToken: sessionToken)
//                SplatNet2.shared.configure(iksmSession: iksmSession)
//                SplatNet2.shared.getResultCoop(jobId: 3549)
//                    .sink(receiveCompletion: { completion in
//                        switch completion {
//                        case .finished:
//                            print("FINISHED")
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }, receiveValue: { response in
//                        print(response)
//                    })
//                    .store(in: &task)
//                SplatNet2.shared.getCookie(sessionToken: sessionToken)
//                    .sink(receiveCompletion: { completion in
//                        switch completion {
//                        case .finished:
//                            print("FINISHED")
//                        case .failure(let error):
//                            print(error)
//                        }
//                    }, receiveValue: { response in
//                        print(response)
//                    })
//                    .store(in: &task)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
