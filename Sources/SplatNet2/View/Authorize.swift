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
    @State var manager: SplatNet2 = SplatNet2()
    
    public typealias CompletionHandler = (Result<Bool, APIError>) -> Void
    let completionHandler: CompletionHandler
    
    public init(isPresented: Binding<Bool>, completionHandler: @escaping CompletionHandler) {
        self._isPresented = isPresented
        self.completionHandler = completionHandler
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
                                completionHandler(.success(true))
                            case .failure(let error):
                                completionHandler(.failure(error))
                            }
                        }, receiveValue: { _ in })
                        .store(in: &task)
                }
            }
    }
}

public extension View {
    func authorize(isPresented: Binding<Bool>, completion: @escaping (Result<Bool, APIError>) -> Void) -> some View {
        self.modifier(Authorize(isPresented: isPresented) { response in
            completion(response)
        })
    }
}
