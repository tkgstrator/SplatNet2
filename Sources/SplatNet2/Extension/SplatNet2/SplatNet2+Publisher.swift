//
//  Publisher.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/13.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Foundation

extension SplatNet2 {
    /// リクエストを実行(IksmSessionを取得)
    func generate(accessToken: String) -> AnyPublisher<IksmSession.Response, SP2Error> {
        session.request(IksmSession(accessToken: accessToken))
            .validate()
            .validate(contentType: ["text/html"])
            .publishString()
            .flatMap({ response -> AnyPublisher<IksmSession.Response, SP2Error> in
                guard let value = response.value,
                      let nsaid = value.capture(pattern: "data-nsa-id=([/0-f/]{16})", group: 1),
                      let header = response.response?.allHeaderFields as? [String: String],
                      let url = response.response?.url,
                      let iksmSession = HTTPCookie.cookies(withResponseHeaderFields: header, for: url).first?.value
                else {
                    return Fail(outputType: IksmSession.Response.self, failure: SP2Error.dataDecodingFailed)
                        .eraseToAnyPublisher()
                }
                return Future { promise in
                    promise(.success(IksmSession.Response(iksmSession: iksmSession, nsaid: nsaid)))
                }
                .eraseToAnyPublisher()
            })
            .handleEvents(receiveSubscription: { subscription in
                // どのリクエストが実行中か返す
                self.delegate?.progressSignIn(state: .iksmSession)
                self.delegate?.willReceiveSubscription(subscribe: subscription)
            }, receiveOutput: { output in
                self.delegate?.willReceiveOutput(output: output)
            }, receiveCompletion: { completion in
//                self.delegate?.willReceiveCompletion(completion: completion)
                self.delegate?.didFinishSplatNet2SignIn()
            }, receiveCancel: {
                self.delegate?.willReceiveCancel()
            }, receiveRequest: { request in
                self.delegate?.willReceiveRequest(request: request)
            })
            .eraseToAnyPublisher()
    }
}
