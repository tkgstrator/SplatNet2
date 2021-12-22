//
//  EnvironmentValues.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/12/21.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Foundation
import SwiftUI

public struct AllowMoveInList: EnvironmentKey {
    public typealias Value = Binding<Bool>

    public static var defaultValue: Binding<Bool> = .constant(false)
}

public extension EnvironmentValues {
    var allowMoveInList: Binding<Bool> {
        get {
            self[AllowMoveInList.self]
        }
        set {
            self[AllowMoveInList.self] = newValue
        }
    }
}
