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

let manager: SplatNet2 = SplatNet2()

struct ContentView: View {

    @State var task = Set<AnyCancellable>()
    @State var isPresented: Bool = false
    @State var environment: Bool = false
    @State var apiError: APIError?

    var body: some View {
        NavigationView {
            Form {
                Section() {
                    Button(action: {
                        isPresented.toggle()
                    }, label: { Text("SIGN IN")})
                    .authorize(isPresented: $isPresented) { completion in
                        print(completion)
                    }
                    Button(action: {
                        getSummaryCoop()
                    }, label: { Text("GET SUMMARY")})
                    Button(action: { getLatestResult() }, label: { Text("GET LATEST RESULT")})
                    Button(action: { getNicknameAndIcons() }, label: { Text("GET PLAYER DATA")})
                }
                AccountPicker()
                Section() {
                    Button(action: { getAllAccounts() }, label: { Text("GET ALL ACCOUNTS") })
                    Button(action: { deleteAllAccounts() }, label: { Text("DELETE ALL ACCOUNTS") })
                }
            }
            .alert(item: $apiError) { error in
                Alert(title: Text("ERROR"), message: Text(error.localizedDescription))
            }
            .navigationTitle("SplatNet2 Demo")
        }
    }

    private func getAllAccounts() {
        let accounts = SplatNet2.getAllAccounts()
        for account in accounts {
            print(account)
        }
    }

    private func deleteAllAccounts() {
        SplatNet2.deleteAllAccounts()
    }
    
    private func getLatestResult() {
        splatNet2.getSummaryCoop(jobNum: 0)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    apiError = error
                }
            }, receiveValue: { response in
                print(response)
                let latestId = response.summary.card.jobNum
                splatNet2.getResultCoop(jobId: latestId)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            apiError = error
                        }
                    }, receiveValue: { response in
                        print(response)
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
        splatNet2.getSummaryCoop()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    apiError = error
                }
            }, receiveValue: { response in
                print(response)
            })
            .store(in: &task)
    }
    
    private func getNicknameAndIcons() {
        let playerId: [String] = [manager.playerId]
        splatNet2.getNicknameAndIcons(playerId: playerId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    apiError = error
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
