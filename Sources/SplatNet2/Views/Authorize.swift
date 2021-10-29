//
//  Authorize.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//

import SwiftUI
import BetterSafariView
import Combine

public struct Authorize: ViewModifier {
    @Binding var isPresented: Bool
    @State var task = Set<AnyCancellable>()
    let manager: SplatNet2
    
    public typealias CompletionHandler = (Result<UserInfo, APIError>) -> Void
    let completionHandler: CompletionHandler
    
    public init(isPresented: Binding<Bool>, manager: SplatNet2, completionHandler: @escaping CompletionHandler) {
        self._isPresented = isPresented
        self.completionHandler = completionHandler
        self.manager = manager
    }
    
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
                                    break
                                case .failure(let error):
                                    completionHandler(.failure(error))
                            }
                        }, receiveValue: { response in
                            manager.addAccount(account: response)
                            manager.account = response
                            completionHandler(.success(response))
                        })
                        .store(in: &task)
                }
            }
    }
}

public extension View {
    func authorize(isPresented: Binding<Bool>, manager: SplatNet2, completion: @escaping (Result<UserInfo, APIError>) -> Void) -> some View {
        self.modifier(Authorize(isPresented: isPresented, manager: manager) { response in
            completion(response)
        })
    }
}
