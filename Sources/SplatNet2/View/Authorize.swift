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

    public func body(content: Content) -> some View {
        content
            .webAuthenticationSession(isPresented: $isPresented) {
                WebAuthenticationSession(url: SplatNet2.oauthURL, callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, _ in
                    guard let code: String = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else { return }
                    SplatNet2().getCookie(sessionTokenCode: code, verifier: SplatNet2.verifier)
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
            .alert(item: $apiError) { error in
                Alert(title: Text("Error"), message: Text(error.localizedDescription))
            }
    }
}

public extension View {
    func authorize(isPresented: Binding<Bool>) -> some View {
        self.modifier(Authorize(isPresented: isPresented))
    }
}
