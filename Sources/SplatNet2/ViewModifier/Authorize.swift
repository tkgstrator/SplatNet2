//
//  Authorize.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import BetterSafariView
import CocoaLumberjackSwift
import Combine
import Common
import SwiftUI

public struct Authorize: ViewModifier {
    @Binding var isPresented: Bool
    @State var task = Set<AnyCancellable>()
    let session: SplatNet2
    let state = String.randomString
    let verifier = String.randomString

    public init(isPresented: Binding<Bool>, session: SplatNet2) {
        self._isPresented = isPresented
        self.session = session
    }

#warning("ゴミコード")
    public func body(content: Content) -> some View {
        content
            .webAuthenticationSession(isPresented: $isPresented) {
                WebAuthenticationSession(
                    url: session.oauthURL(state: state, verifier: verifier),
                    callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, error in
                        do {
                            // Session State
                            guard let _: String = callbackURL?.absoluteString.capture(pattern: "state=(.*)&session", group: 1) else {
                                throw SP2Error.oauthValidationFailed(reason: .invalidSessionState)
                            }

                            // State
                            guard let state: String = callbackURL?.absoluteString.capture(pattern: "&state=(.*)", group: 1) else {
                                throw SP2Error.oauthValidationFailed(reason: .invalidState)
                            }

                            if state != self.state {
                                throw SP2Error.oauthValidationFailed(reason: .stateMatchFailed)
                            }

                            // Session Token Code
                            guard let code: String = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else {
                                throw SP2Error.oauthValidationFailed(reason: .invalidSessionTokenCode)
                            }
                            session.getCookie(code: code, verifier: verifier)
                                .sink(receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):
                                        session.delegate?.failedWithSP2Error(error: error)
                                    }
                                }, receiveValue: { response in
                                    session.account = response
                                    session.delegate?.didFinishSplatNet2SignIn(account: response)
                                })
                                .store(in: &task)
                        } catch {
                            if let error = error.asSP2Error {
                                session.delegate?.failedWithSP2Error(error: error)
                            }
                        }
                }
            }
    }
}

public extension View {
    func authorize(isPresented: Binding<Bool>, session: SplatNet2) -> some View {
        self.modifier(Authorize(isPresented: isPresented, session: session))
    }
}
