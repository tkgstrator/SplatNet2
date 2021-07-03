//
//  Authorize.swift
//  
//
//  Created by devonly on 2021/07/03.
//

import SwiftUI
import BetterSafariView
import Combine

public struct Authorize: ViewModifier {
    @Binding var isPresented: Bool
    @State var task = Set<AnyCancellable>()
    @State var apiError: APIError?
    @State var manager: SplatNet2 = SplatNet2()

    public func body(content: Content) -> some View {
        content
            .webAuthenticationSession(isPresented: $isPresented) {
                WebAuthenticationSession(url: SplatNet2.oauthURL, callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, _ in
                    guard let code: String = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { return }
                    manager.getCookie(sessionTokenCode: code, verifier: SplatNet2.verifier)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                print("FINISHED")
                            case .failure(let error):
                                apiError = error
                            }
                        }, receiveValue: { response in
                            let nsaid = response.nsaid
                            manager = SplatNet2(nsaid: nsaid)
                            print(response)
                        })
                        .store(in: &task)
                }
            }
    }
}

public extension View {
    func authorize(isPresented: Binding<Bool>) -> some View {
        self.modifier(Authorize(isPresented: isPresented))
    }
}
