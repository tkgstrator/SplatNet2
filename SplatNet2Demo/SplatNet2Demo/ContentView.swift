//
//  ContentView.swift
//  SplatNet2Demo
//
//  Created by devonly on 2021/05/01.
//

import SwiftUI
import SplatNet2
import Combine
import BetterSafariView

struct ContentView: View {
    @State var task = Set<AnyCancellable>()
    @State var isPresented: Bool = false
    var body: some View {
        Form {
            Button(action: {
                SplatNet2.shared.version = "1.10.1"
                isPresented.toggle()
            }, label: { Text("SIGN IN")})
                .webAuthenticationSession(isPresented: $isPresented) {
                    WebAuthenticationSession(url: SplatNet2.shared.oauthURL, callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, _ in
                        guard let code: String = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { return }
                        SplatNet2.shared.getCookie(sessionTokenCode: code)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    print("FINISHED")
                                case .failure(let error):
                                    print(error.errorDescription)
                                }
                            }, receiveValue: { response in
                                    print(response)
                            })
                            .store(in: &task)
                    }
                }
            Button(action: { getSummaryCoop() }, label: { Text("GET SUMMARY")})
            Button(action: { getLatestResult() }, label: { Text("GET LATEST RESULT")})
            Button(action: { getNicknameAndIcons() }, label: { Text("GET PLAYER DATA")})
        }
    }
    
    private func getLatestResult() {
        SplatNet2.shared.getSummaryCoop()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { response in
                let latestId = response.summary.card.jobNum
                SplatNet2.shared.getResultCoop(jobId: latestId)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print(error)
                        }
                    }, receiveValue: { response in
                        print("APPEAR", response.bossCounts)
                        print("KILL", response.bossKillCounts)
                        for player in response.results {
                            print("PLAYER", player.bossKillCounts)
                        }
                    })
                    .store(in: &task)
            })
            .store(in: &task)
    }
    
    private func getSummaryCoop() {
        SplatNet2.shared.getSummaryCoop()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.errorDescription)
                }
            }, receiveValue: { response in
                    print(response)
            })
            .store(in: &task)
    }
    
    private func getNicknameAndIcons() {
        let playerId: [String] = ["3f89c3791c43ea57", "fc324b472a0dbb78"]
        SplatNet2.shared.getNicknameAndIcons(playerId: playerId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { response in
                    print(response)
            })
            .store(in: &task)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }

    private func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else { return [] }
        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
