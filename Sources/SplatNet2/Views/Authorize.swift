//
//  Authorize.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import BetterSafariView
import Combine
import SwiftUI

public struct Authorize: ViewModifier {
    @Binding var isPresented: Bool
    @State var task = Set<AnyCancellable>()
    @State var sp2Error: SP2Error?
    let manager: SplatNet2
    let state = String.randomString
    let verifier = String.randomString

    public typealias CompletionHandler = (Swift.Result<UserInfo, SP2Error>) -> Void
    let completionHandler: CompletionHandler

    public init(isPresented: Binding<Bool>, manager: SplatNet2, completionHandler: @escaping CompletionHandler) {
        self._isPresented = isPresented
        self.completionHandler = completionHandler
        self.manager = manager
    }

    public func body(content: Content) -> some View {
        content
            .webAuthenticationSession(isPresented: $isPresented) {
                WebAuthenticationSession(
                    url: manager.oauthURL(state: state, verifier: verifier),
                    callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, error in
                    do {
                        // Domain
                        // swiftlint:disable unused_optional_binding
                        if let _ = error {
                            throw SP2Error.userCancelled
                        }

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

                        manager.getCookie(code: code, verifier: verifier)
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    break
                                case .failure(let error):
                                    sp2Error = error
                                }
                            }, receiveValue: { response in
                                // 利用しているアカウントを新しいものに上書きする
                                manager.account = response
                            })
                            .store(in: &task)
                    } catch let error as SP2Error {
                        print(error)
                        sp2Error = error
                    } catch {
                        print(error)
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
    func authorize(isPresented: Binding<Bool>, manager: SplatNet2, completion: @escaping (Swift.Result<UserInfo, SP2Error>) -> Void) -> some View {
        self.modifier(Authorize(isPresented: isPresented, manager: manager) { response in
            completion(response)
        }
        )
    }
}
