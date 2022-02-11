//
//  SignInState.swift
//  SplatNet2
//
//  Created by tkgstrator on 2022/02/05.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation

public enum SignInState: Identifiable {
    case sessionToken(LoginType)
    case accessToken(LoginType)
    case s2sHash(LoginType)
    case flapg(LoginType)
    case iksmSession

    public var id: Int { progress }

    public var progress: Int {
        switch self {
            case .sessionToken(let value):
                return value == .nso ? 0 : 4
            case .accessToken(let value):
                return value == .nso ? 1 : 7
            case .s2sHash(let value):
                return value == .nso ? 2 : 5
            case .flapg(let value):
                return value == .nso ? 3 : 6
            case .iksmSession:
                return 8
        }
    }

    public enum LoginType: CaseIterable {
        case nso
        case app
    }
}
