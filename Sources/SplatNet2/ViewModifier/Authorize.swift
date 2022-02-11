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
    @State var sp2Error: SP2Error?
    let session: SplatNet2
    let state = String.randomString
    let verifier = String.randomString

    public typealias CompletionHandler = (Swift.Result<UserInfo, SP2Error>) -> Void

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
                                    DDLogInfo("Login Success")
                                case .failure(let error):
                                    sp2Error = error
                                }
                            }, receiveValue: { response in
                                // アカウントを追加する
                                #warning("ここの処理をExtensionで実装します")
                                session.account = response
                                session.delegate?.didFinishSplatNet2SignIn(account: response)
                            })
                            .store(in: &task)
                    } catch {
                        guard let error = error.asSP2Error else {
                            DDLogError(error.localizedDescription)
                            return
                        }
                        DDLogError(error.localizedDescription)
                    }
                }
            }
            .alert(item: $sp2Error, content: { error in
                Alert(
                    title: Text("Error \(String(format: "%04d", error.errorCode))"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("Dismiss"))
                )
            })
    }
}

public extension View {
    func authorize(isPresented: Binding<Bool>, session: SplatNet2) -> some View {
        self.modifier(Authorize(isPresented: isPresented, session: session))
    }
}
