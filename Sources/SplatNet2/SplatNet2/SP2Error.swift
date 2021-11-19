//
//  SP2Error.swift
//  SplatNet2
//
//  Created by tkgstrator on 2021/05/06.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//

import Alamofire
import Foundation

public enum SP2Error: Error {
    /// ログイン時のエラー
    case Session(Http, Failure?, AFError?)
    /// 認証時のエラー
    case OAuth(Token, Error?)
    /// 共通エラー
    case Common(Http, AFError)
    /// 共通エラー
    case Data(Decode, Error?)

    public enum Token: Int, CaseIterable {
        /// Stateが一致しない
        case state      = 8_400
        /// Codeが含まれない
        case code       = 8_401
        /// Session Stateが一致しない
        case session    = 8_402
        /// ユーザがキャンセルした
        case domain     = 8_403
        /// レスポンスが不正
        case response   = 8_404
    }

    public enum Http: Int, CaseIterable {
        /// 400: Bad request
        case badrequest     = 400
        /// 401: Unauthorized
        case unauthorized   = 401
        /// 403: Forbidden
        case forbidden      = 403
        /// 404: Not found
        case notfound       = 404
        /// 405: Not allowed method
        case notallowed     = 405
        /// 406: Unacceptable
        case unacceptable   = 406
        /// 408: Timeout
        case timeout        = 408
        /// 427: Upgrade required
        case upgrade        = 427
        /// 429: Too many requests
        case manyrequests   = 429
        /// 430: No new results
        case nonewresults   = 430
        /// 503: Server is unavailable
        case unavailable    = 503
    }

    public enum Decode: Int, CaseIterable {
        /// 432: Undecodable
        case undecodable    = 9_432
        /// 433: Invalid response
        case response       = 9_433
        /// 444: Unknown error
        case unknown        = 9_444
    }

    /// ステータスコード
    var statusCode: Int {
        switch self {
        case .Session(let value, let response, _):
            guard let status = response?.status else {
                return value.rawValue
            }
            return status
        case .Common(let value, _):
            return value.rawValue
        case .OAuth(let value, _):
            return value.rawValue
        case .Data(let value, _):
            return value.rawValue
        }
    }

    /// 
    public struct Failure: Codable {
        let errorDescription: String?
        let error: String?
        let errorMessage: String?
        let status: Int?
        let correlationId: String?
    }
}

extension SP2Error: LocalizedError {
    /// エラーの詳細を返す
    public var errorDescription: String? {
        switch self {
        case .Session(_, let response, _):
            return [response?.errorDescription, response?.errorMessage].compactMap({ $0 }).first
        case .Common(_, let error):
            return error.localizedDescription
        case .OAuth(let error, _):
            switch error {
            case .domain:
                return "Authorization is cancelled by user."
            case .code:
                return "Provided code is invalied/empty."
            case .state:
                return "Provided state is not match."
            case .session:
                return "Provided session state is invalid."
            case .response:
                return "Provided iksm_session is invalid."
            }
        case .Data:
            return "Invalid response."
        }
    }
}

extension SP2Error: Identifiable {
    public var id: Int { self.statusCode }
}

extension String {
    var localized: String {
        let bundle = Bundle.module
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
