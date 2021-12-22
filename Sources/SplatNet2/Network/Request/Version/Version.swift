//
//  Version.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/07/03.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

public class Version: Codable {
    /// X-Product Version
    public var version: String = "1.13.2"
    /// Service Name
    public var service: String = "Salmonia3/@tkgling"
    /// Release Date(ISO8601 format)
    public var releaseDate: String = "2021-10-01T:00:00:00Z"
    /// SplatNet2 Account
    public var accounts: [UserInfo]

    internal init(accounts: [UserInfo]) {
        self.accounts = accounts
    }

    internal init(version: String, accounts: [UserInfo]) {
        self.version = version
        self.accounts = accounts
    }

    internal init(version: String, releaseDate: String, accounts: [UserInfo]) {
        self.version = version
        self.releaseDate = releaseDate
        self.accounts = accounts
    }
}
