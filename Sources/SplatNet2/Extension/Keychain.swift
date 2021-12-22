//
//  Keychain.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/05/01.
//  Copyright © 2021 Magi, Corporation. All rights reserved.

import Foundation
import KeychainAccess

extension Keychain {
    /// Account
    var scheme: String { "SplatNet2" }
    /// X-Product Version
    var version: String { "X-Product Version" }
    /// JSONEncoder
    var encoder: JSONEncoder { JSONEncoder() }
    /// JSONDecoder
    var decoder: JSONDecoder { JSONDecoder() }

    // X-Product Versionを取得
    func getVersion() -> String {
        guard let version = try? get(self.version) else {
            return "1.13.2"
        }
        return version
    }

    func setVersion(version: String?) {
        if let version = version {
            try? set(version, key: self.version)
        }
    }

    /// アカウントを取得
    func getValue() -> [UserInfo] {
        guard let data = try? getData(scheme),
              let result = try? decoder.decode([UserInfo].self, from: data)
        else {
            return []
        }
        return result
    }

    /// アカウントを一括追加
    func setValue(_ objects: [UserInfo]) throws {
        try set(try encoder.encode(objects), key: scheme)
    }

    /// アカウント情報をアップデート
    func setValue(_ object: UserInfo) throws {
        try setValue((getValue()).filter({ $0.credential.nsaid != object.credential.nsaid }) + [object])
    }

    /// アカウントの並び替え
    func move(from source: IndexSet, to destination: Int) throws {
        var objects = getValue()
        objects.move(fromOffsets: source, toOffset: destination)
        try setValue(objects)
    }

    /// アカウントの削除
    func delete(at offsets: IndexSet) throws {
        var objects = getValue()
        objects.remove(atOffsets: offsets)
        try setValue(objects)
    }
}
