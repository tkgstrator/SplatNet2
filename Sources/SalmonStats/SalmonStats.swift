//
//  SalmonStats.swift
//  SalmonStats
//
//  Created by tkgstrator on 2021/04/10.
//  Copyright © 2021 Magi, Corporation. All rights reserved.
//  

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation
import KeychainAccess
import SplatNet2

open class SalmonStats {
    /// アクセス用のセッション
    public let session: Session = {
        let configuration: URLSessionConfiguration = {
            let config = URLSessionConfiguration.default
            config.httpMaximumConnectionsPerHost = 1
            config.timeoutIntervalForRequest = 5
            return config
        }()
        return Session(configuration: configuration)
    }()

    // JSON Decoder
    public let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    @Published var task: Set<AnyCancellable> = Set<AnyCancellable>()
    let keychain = Keychain(service: "SalmonStats")
    private weak var delegate: SalmonStatsSessionDelegate?

    public init(delegate: SalmonStatsSessionDelegate? = nil) {
        self.delegate = delegate
    }

    /// アップロード用の認証トークン
    public var apiToken: String? {
        get {
            keychain.getAPIToken()
        }
        set {
            keychain.setAPIToken(apiToken: newValue)
        }
    }

    /// メタデータを取得
    public func getMetadata(nsaid: String) -> AnyPublisher<[Metadata.Response], SP2Error> {
        let request = Metadata(nsaid: nsaid)
        return publish(request)
    }

    /// プレイヤーメタデータを取得
    public func getPlayerMetadata(nsaid: String) -> AnyPublisher<[Player.Response], SP2Error> {
        let request = Player(nsaid: nsaid)
        return publish(request)
    }

    /// SplatNet2からリザルトを取得してアップロード
    public func uploadResult(resultId: Int) -> AnyPublisher<[UploadResult.Response], SP2Error>? {
        delegate?.uploadResult(resultId: resultId)
    }

    /// SplatNet2からリザルトを取得してアップロード
    public func uploadResults(resultId: Int?) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error>? {
        delegate?.uploadResults(resultId: resultId)
    }

    /// リザルトを取得
    public func getResults(from: Int, to: Int) -> AnyPublisher<[CoopResult.Response], SP2Error> {
        Future { [self] promise in
            (from ... to).publisher
                .flatMap(maxPublishers: .max(1), { getResults(pageId: $0) })
                .collect()
                .sink(receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: { response in
                    promise(.success(response.flatMap({ $0 })))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }

    /// リザルトを取得(pageId)
    private func getResults(pageId: Int, count: Int = 50) -> AnyPublisher<[CoopResult.Response], SP2Error> {
        guard let nsaid = delegate?.nsaid
        else {
            return Fail(outputType: [CoopResult.Response].self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        let request = ResultsStats(nsaid: nsaid, pageId: pageId, count: count)
        return Future { [self] promise in
            publish(request)
                .sink(receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: { response in
                    promise(.success(response.results.map({ CoopResult.Response(from: $0, playerId: nsaid) })))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }

    /// リザルトを取得(resultId)
    public func getResult(resultId: Int) -> AnyPublisher<CoopResult.Response, SP2Error> {
        guard let nsaid = delegate?.nsaid
        else {
            return Fail(outputType: CoopResult.Response.self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        let request = ResultStats(resultId: resultId)
        return Future { [self] promise in
            publish(request)
                .subscribe(on: DispatchQueue(label: "SalmonStats"))
                .receive(on: DispatchQueue(label: "SalmonStats"))
                .sink(receiveCompletion: { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }, receiveValue: { response in
                    promise(.success(CoopResult.Response(from: response, playerId: nsaid)))
                })
                .store(in: &task)
        }
        .eraseToAnyPublisher()
    }

    /// リクエストを実行
    internal func publish<T: RequestType>(_ request: T) -> AnyPublisher<T.ResponseType, SP2Error> {
        session
            .request(request)
            .cURLDescription { request in
                DDLogInfo(request)
            }
            .validationWithSP2Error(decoder: decoder)
            .publishDecodable(type: T.ResponseType.self, decoder: decoder)
            .value()
            .handleEvents(receiveSubscription: { _ in
//                self.delegate?.willReceiveSubscription(subscribe: subscription)
            }, receiveOutput: { _ in
//                self.delegate?.willReceiveOutput(output: output)
            }, receiveCompletion: { _ in
//                self.delegate?.willReceiveCompletion(completion: completion)
            }, receiveCancel: {
//                self.delegate?.willReceiveCancel()
            }, receiveRequest: { _ in
//                self.delegate?.willReceiveRequest(request: request)
            })
            .mapError({ error -> SP2Error in
                DDLogError(error)
                guard let sp2Error = error.asSP2Error else {
                    return SP2Error.requestAdaptionFailed
                }
                return sp2Error
            })
            .eraseToAnyPublisher()
    }
}
