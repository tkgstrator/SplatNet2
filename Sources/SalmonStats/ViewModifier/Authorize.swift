//
//  Authorize.swift
//  
//
//  Created by devonly on 2021/10/19.
//

import SwiftUI
import SplatNet2
import BetterSafariView
import Combine

public struct Authorize: ViewModifier {
    @Binding var isPresented: Bool
    @State var task = Set<AnyCancellable>()
    let session: SalmonStats
    
    public typealias CompletionHandler = (Result<String, APIError>) -> Void
    let completionHandler: CompletionHandler
    
    public init(isPresented: Binding<Bool>, session: SalmonStats, completionHandler: @escaping CompletionHandler) {
        self._isPresented = isPresented
        self.completionHandler = completionHandler
        self.session = session
    }
    
    public func body(content: Content) -> some View {
        content
            .webAuthenticationSession(isPresented: $isPresented, content: {
                WebAuthenticationSession(url: URL(string: "https://salmon-stats-api.yuki.games/auth/twitter")!, callbackURLScheme: "salmon-stats") { callbackURL, _ in
                    if let apiToken = callbackURL?.absoluteString.capture(pattern: "api-token=(.*)", group: 1) {
                        session.apiToken = apiToken
                        completionHandler(.success(apiToken))
                    } else {
                        completionHandler(.failure(.response))
                    }
                }
                .prefersEphemeralWebBrowserSession(false)
            })
    }
}

public extension View {
    func authorize(isPresented: Binding<Bool>, session: SalmonStats, completion: @escaping (Result<String, APIError>) -> Void) -> some View {
        self.modifier(Authorize(isPresented: isPresented, session: session) { response in
            completion(response)
        })
    }
}
