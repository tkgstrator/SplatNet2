//
//  SplatNet2SessionDelegate.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/06/27.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Combine
import Foundation

public protocol SplatNet2SessionDelegate: NSObject {
    /// セッション購読時の処理
    func willReceiveSubscription(subscribe: Subscription)
    /// レスポンス受信時の処理
    func willReceiveOutput(output: Decodable & Encodable)
    /// セッション終了時の処理
    func willReceiveCompletion(completion: Subscribers.Completion<AFError>)
    /// セッションキャンセル時の処理
    func willReceiveCancel()
    /// リクエスト受理時の処理
    func willReceiveRequest(request: Subscribers.Demand)
    /// サインインの進行具合を表示
    func progressSignIn(state: SignInState)
    /// 取得可能なリザルトと現在リザルトを返す
    func isAvailableResults(current: Int, maximum: Int)
    /// サインインが終わったときに呼ばれる
    func didFinishSplatNet2SignIn()
    /// X-Product Versionが低いときに呼ばれる
    func failedWithUnavailableVersion(version: String)
}
