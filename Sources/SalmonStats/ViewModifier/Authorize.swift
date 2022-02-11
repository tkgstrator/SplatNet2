//
//  Authorize.swift
//  
//
//  Created by devonly on 2021/10/19.
//

import BetterSafariView
import Combine
import Foundation
import SplatNet2
import SwiftUI

public struct Authorize: ViewModifier {
    @Binding var isPresented: Bool
    @State var task = Set<AnyCancellable>()
    let session: SalmonStats
    let oauthURL = URL(unsafeString: "https://salmon-stats-api.yuki.games/auth/twitter")

    public typealias CompletionHandler = (Result<String, SP2Error>) -> Void

    public init(isPresented: Binding<Bool>, session: SalmonStats) {
        self._isPresented = isPresented
        self.session = session
    }

    public func body(content: Content) -> some View {
        content
            .webAuthenticationSession(isPresented: $isPresented, content: {
                WebAuthenticationSession(url: oauthURL, callbackURLScheme: "salmon-stats") { callbackURL, _ in
                    if let apiToken = callbackURL?.absoluteString.capture(pattern: "api-token=(.*)", group: 1) {
                        session.apiToken = apiToken
                    } else {
                        session.delegate?.failedWithSP2Error(error: SP2Error.credentialFailed)
                    }
                }
                .prefersEphemeralWebBrowserSession(false)
            })
    }
}

public extension View {
    func authorizeToken(
        isPresented: Binding<Bool>,
        session: SalmonStats
    ) -> some View {
        self.modifier(Authorize(isPresented: isPresented, session: session))
    }
}
