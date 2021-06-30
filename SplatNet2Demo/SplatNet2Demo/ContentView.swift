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
import KeychainAccess

struct ContentView: View {
    @State var task = Set<AnyCancellable>()
    @State var isPresented: Bool = false
    @State var environment: Bool = false
    @State var apiError: Response.APIError?
    
    var body: some View {
        Form {
            Section() {
                Button(action: {
                    isPresented.toggle()
                }, label: { Text("SIGN IN")})
                .webAuthenticationSession(isPresented: $isPresented) {
                    WebAuthenticationSession(url: splatNet2.oauthURL, callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, _ in
                        guard let code: String = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { return }
                        splatNet2.getCookie(sessionTokenCode: code)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    print("FINISHED")
                                case .failure(let error):
                                    print(error)
                                }
                            }, receiveValue: { response in
                                let nsaid = response.nsaid
                                splatNet2 = SplatNet2(nsaid: nsaid)
                                print(response)
                            })
                            .store(in: &task)
                    }
                }
                Button(action: {
                    getSummaryCoop()
                }, label: { Text("GET SUMMARY")})
                Button(action: { getLatestResult() }, label: { Text("GET LATEST RESULT")})
                Button(action: { getNicknameAndIcons() }, label: { Text("GET PLAYER DATA")})
            }
            Section() {
                Toggle(isOn: $environment, label: { Text("ENVIRONMENT") })
                Button(action: { deleteIksmSession() }, label: { Text("DELETE IKSM SESSION") })
                Button(action: { getKeychainServer() }, label: { Text("KEYCHAIN DATA") })
                Button(action: { deleteKeychainData() }, label: { Text("DEKETE KEYCHAIN") })
            }
        }
    }
    
    private func deleteIksmSession() {
        print(splatNet2.getAllAccounts())
    }
    
    private func getKeychainServer() {
        let keychains = Keychain.allItems(.internetPassword)
        
        for keychain in keychains {
            let server = keychain["server"]
            let key = keychain["key"] as! String
            print("\(server): \(key) -> \(keychain["value"])")
        }
    }
    
    private func deleteKeychainData() {
        let keychains = Keychain.allItems(.internetPassword)
        
        for keychain in keychains {
            let server = keychain["server"] as! String
            let key = keychain["key"]
            
            if let url = URL(string: server) {
                let keychain = Keychain(server: url, protocolType: .https)
                keychain[key as! String] = nil
            } else {
                let keychain = Keychain(server: "work.tkgstrator", protocolType: .https)
                keychain[key as! String] = nil
            }
        }
    }
    
    private func getLatestResult() {
        splatNet2.getSummaryCoop()
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
                let latestId = response.summary.card.jobNum
                splatNet2.getResultCoop(jobId: latestId)
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
                    print(error)
                }
            }, receiveValue: { response in
                print(response)
            })
            .store(in: &task)
    }
    
    private func getNicknameAndIcons() {
        let playerId: [String] = ["3f89c3791c43ea57", "fc324b472a0dbb78"]
        splatNet2.getNicknameAndIcons(playerId: playerId)
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
