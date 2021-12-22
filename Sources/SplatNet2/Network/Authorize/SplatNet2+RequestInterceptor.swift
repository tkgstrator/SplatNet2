//
//  SplatNet2+RequestInterceptor.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Foundation
import KeychainAccess

extension SplatNet2: RequestInterceptor {
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        guard let url = urlRequest.url?.absoluteString else {
            completion(.success(urlRequest))
            return
        }
        DDLogInfo(url)

        // ユーザーエージェントの追加
        urlRequest.headers.add(.userAgent(userAgent))

        // X-ProductVersionの追加
        if url.contains("api-lp1.znc.srv") {
            urlRequest.headers.update(name: "X-ProductVersion", value: keychain.getVersion())
        }
        completion(.success(urlRequest))
        return
    }

    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // リトライ回数が一定以上の場合は強制終了する
        if request.retryCount >= 2, task.count >= 2 {
            completion(.doNotRetry)
            return
        }

        // エラーが変換できない場合も終了する
        guard let sp2Error = error.asSP2Error else {
            completion(.doNotRetry)
            return
        }
        DDLogError(request.request!.url!.absoluteString)
        DDLogError(sp2Error)

        // エラーコードが427のときのみX-ProductVersionのアップデートを行う
        if sp2Error.errorCode == 9_427 {
            getVersion()
                .sink(receiveCompletion: { result in
                    switch result {
                        case .finished:
                            completion(.retry)
                            return
                        case .failure(let error):
                            DDLogError(error)
                            completion(.doNotRetry)
                            return
                    }
                }, receiveValue: { response in
                    // 取得した新たなX-ProductVersionを上書きする
                    if let version = response.results.first?.version {
                        self.version = version
                    }
                })
                .store(in: &task)
        } else {
            completion(.doNotRetry)
            return
        }
    }
}
