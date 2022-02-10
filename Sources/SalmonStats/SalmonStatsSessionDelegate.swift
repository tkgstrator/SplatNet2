//
//  SalmonStatsSessionDelegate.swift
//  
//
//  Created by devonly on 2022/02/10.
//

import Alamofire
import CocoaLumberjackSwift
import Combine
import Common
import Foundation
import SplatNet2

public protocol SalmonStatsSessionDelegate: AnyObject {
    /// プレイヤーID
    var nsaid: String { get }
    /// 認証トークン
    var apiToken: String? { get set }
    /// タスク管理
    var task: Set<AnyCancellable> { get set }
    /// 指定されたIDのリザルトを取得してアップロード
    func uploadResult(resultId: Int) -> AnyPublisher<[UploadResult.Response], SP2Error>?
    /// 指定されたIDから最新までのリザルトを取得してアップロード
    func uploadResults(resultId: Int?) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error>?
    /// メタデータを取得
    func getMetadata(nsaid: String) -> AnyPublisher<[Metadata.Response], SP2Error>
    /// プレイヤーメタデータを取得
    func getPlayerMetadata(nsaid: String) -> AnyPublisher<[Player.Response], SP2Error>
    /// SplatNet2からリザルトを取得してアップロード
    func getResults(from: Int, to: Int) -> AnyPublisher<[CoopResult.Response], SP2Error>
    /// SplatNet2からリザルトを取得してアップロード
    func getResults(pageId: Int, count: Int) -> AnyPublisher<[CoopResult.Response], SP2Error>
    /// リザルトを取得
    func getResult(resultId: Int) -> AnyPublisher<CoopResult.Response, SP2Error>
}

public extension SalmonStatsSessionDelegate {
    // JSON Decoder
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// メタデータを取得
    func getMetadata(nsaid: String) -> AnyPublisher<[Metadata.Response], SP2Error> {
        let request = Metadata(nsaid: nsaid)
        return publish(request)
    }

    /// プレイヤーメタデータを取得
    func getPlayerMetadata(nsaid: String) -> AnyPublisher<[Player.Response], SP2Error> {
        let request = Player(nsaid: nsaid)
        return publish(request)
    }

    /// リザルトを取得
    func getResults(from: Int, to: Int) -> AnyPublisher<[CoopResult.Response], SP2Error> {
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
    func getResults(pageId: Int, count: Int = 50) -> AnyPublisher<[CoopResult.Response], SP2Error> {
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
    func getResult(resultId: Int) -> AnyPublisher<CoopResult.Response, SP2Error> {
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
        AF.request(request)
            .cURLDescription { request in
                DDLogInfo(request)
            }
        //            .validationWithSP2Error(decoder: decoder)
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
