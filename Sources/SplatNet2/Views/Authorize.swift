//
//  Authorize.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//

import BetterSafariView
import Combine
import SwiftUI

public struct Authorize: ViewModifier {
    @Binding var isPresented: Bool
    @State var task = Set<AnyCancellable>()
    @State var sp2Error: SP2Error?
    let manager: SplatNet2
    let state: String = String.randomString
    let verifier: String = String.randomString
    
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
                WebAuthenticationSession(url: manager.oauthURL(state: state, verifier: verifier), callbackURLScheme: "npf71b963c1b7b6d119") { callbackURL, error in
                    do {
                        // Domain
                        if let _ = error { throw SP2Error.OAuth(.domain, nil) }
                        
                        // Session State
                        guard let session_state: String = callbackURL?.absoluteString.capture(pattern: "state=(.*)&session", group: 1) else {
                            throw SP2Error.OAuth(.session, nil)
                        }
                        
                        // State
                        guard let state: String = callbackURL?.absoluteString.capture(pattern: "&state=(.*)", group: 1) else {
                            throw SP2Error.OAuth(.state, nil)
                        }
                        
                        if state != self.state {
                            throw SP2Error.OAuth(.state, nil)
                        }

                        // Session Token Code
                        guard let code: String = callbackURL?.absoluteString.capture(pattern: "de=(.*)&", group: 1) else {
                            throw SP2Error.OAuth(.code, nil)
                        }
                        manager.getCookie(code: code, verifier: verifier)
                            .sink(receiveCompletion: { completion in
                                switch completion {
                                    case .finished:
                                        break
                                    case .failure(let error):
                                        sp2Error = error
                                        print(error)
                                }
                            }, receiveValue: { response in
                                // 利用しているアカウントを新しいものに上書きする
                                manager.account = response
                            })
                            .store(in: &task)
                    } catch (let error as SP2Error) {
                        sp2Error = error
                    } catch {
                    }
                }
            }
            .alert(item: $sp2Error, content: { error in
                Alert(title: Text("Error \(String(format: "%04d", error.statusCode))"), message: Text(error.localizedDescription), dismissButton: .default(Text("Dismiss")))
            })
    }
}

public extension View {
    func authorize(isPresented: Binding<Bool>, manager: SplatNet2, completion: @escaping (Swift.Result<UserInfo, SP2Error>) -> Void) -> some View {
        self.modifier(Authorize(isPresented: isPresented, manager: manager) { response in
            completion(response)
        })
    }
}
