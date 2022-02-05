//
//  SplatNet2SessionDelegate.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/06/27.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public protocol SplatNet2SessionDelegate {
    /// セッション開始時に呼ばれる
    func willSessionRunning()
    /// セッション終了時に呼ばれる
    func didSessionRunning()
    /// サインインの進行具合を表示
    func isSignInProgress(state: SignInState)
    /// 取得可能なリザルトと現在リザルトを返す
    func isAvailableResults(current: Int, maximum: Int)
}
