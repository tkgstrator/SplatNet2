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
                    .authorize(isPresented: $isPresented)
                    Button(action: {
                        getSummaryCoop()
                    }, label: { Text("GET SUMMARY")})
                    Button(action: { getLatestResult() }, label: { Text("GET LATEST RESULT")})
                    Button(action: { getNicknameAndIcons() }, label: { Text("GET PLAYER DATA")})
                }
                AccountPicker()
                Section() {
                    Button(action: { getKeychainData() }, label: { Text("PRINT KEYCHAIN") })
                }
                Section() {
                    Toggle(isOn: $environment, label: { Text("ENVIRONMENT") })
                    Button(action: { deleteIksmSession() }, label: { Text("DELETE IKSM SESSION") })
                    Button(action: { getKeychainServer() }, label: { Text("KEYCHAIN DATA") })
                    Button(action: { deleteKeychainData() }, label: { Text("DELETE KEYCHAIN") })
                }
            }
            .alert(item: $apiError) { error in
                Alert(title: Text("ERROR"), message: Text(error.localizedDescription))
            }
            .navigationTitle("SplatNet2 Demo")
        }
    }
    
    private func deleteIksmSession() {
//        print(Keychain.getAllAccounts())
    }
    
    private func getKeychainData() {
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
        let playerId: [String] = ["3f89c3791c43ea57", "fc324b472a0dbb78"]
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
