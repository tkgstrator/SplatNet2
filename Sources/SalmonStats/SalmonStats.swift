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

public class SalmonStats: SplatNet2 {
    /// 認証用のAPIToken
    public internal(set) var apiToken: String? {
        get {
            keychain.getAPIToken()
        }
        set {
            keychain.setAPIToken(apiToken: newValue)
        }
    }
    
    /// APITokenをセット
    override public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        /// SalmonStats用の処理を実行
        var urlRequest: URLRequest = urlRequest
        
        guard let url = urlRequest.url?.absoluteString else {
            completion(.failure(SP2Error.requestAdaptionFailed))
            return
        }
        
        switch url.contains("salmon-stats") {
        case true:
            guard let apiToken = apiToken else {
                completion(.failure(SP2Error.credentialFailed))
                return
            }
            urlRequest.headers.add(.authorization(bearerToken: apiToken))
        case false:
            break
        }
        /// 親クラスの処理を実行
        super.adapt(urlRequest, for: session, completion: completion)
    }
    
    public func getMetadata() -> AnyPublisher<[Metadata.Response], SP2Error> {
        if accounts.isEmpty {
            return Fail(outputType: [Metadata.Response].self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        let request = Metadata(nsaid: account.credential.nsaid)
        return publish(request)
    }
    
    /// 一件だけSalmon Statsにデータをアップロード
    public func uploadResults(result: CoopResult.Response) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error> {
        uploadResults(results: [result])
    }
    
    /// Salmon Statsは同時に10件までしかアップロードできない
    /// 10件ずつに分割してアップロード
    private func uploadResults(results: [CoopResult.Response]) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error> {
        results.chunked(by: 10)
            .map({ UploadResult(results: $0) })
            .publisher
            .flatMap({ [self] in publish($0) })
            .collect()
            .map({ zip($0.flatMap({ $0 }), results).compactMap({ ($0.0, $0.1) }) })
            .eraseToAnyPublisher()
    }
    
    /// 一件だけリザルトアップロード
    public func uploadResult(resultId: Int) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error> {
        getCoopResult(resultId: resultId)
            .flatMap({ [self] in uploadResults(result: $0) })
            .eraseToAnyPublisher()
    }
    
    /// New! Salmon StatsにWAVE記録をアップロード
    public func uploadWaveResults(results: [CoopResult.Response]) -> AnyPublisher<UploadWave.Response, SP2Error> {
        let request = UploadWave(results)
        return publish(request)
    }
    
    /// New! Salmon StatsからWAVE記録をダウンロード
    public func getWaveResults(startTime: Int) -> AnyPublisher<ResultWave.Response, SP2Error> {
        let request = ResultWave(startTime: startTime)
        return publish(request)
    }
    
    /// 指定したリザルトIDからSalmon Statsに記録をアップロード
    public func uploadResults(resultId: Int? = nil) {
        if apiToken == .none {
            delegate?.failedWithSP2Error(error: .credentialFailed)
            return
        }
        
        getCoopResults(resultId: resultId)
            .flatMap({ [self] in uploadResults(results: $0) })
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [self] response in
                let results = response.map({ SalmonResult(result: $0) })
                /// 取得したリザルトを返す
                if let delegate = self.delegate as? SalmonStatsSessionDelegate {
                    delegate.didFinishLoadResultsFromSplatNet2(results: results)
                }
            })
            .store(in: &task)
    }

    /// リクエストを実行
    internal func publish<T: RequestType>(_ request: T) -> AnyPublisher<T.ResponseType, SP2Error> {
        session
            .request(request, interceptor: self)
            .cURLDescription { request in
                DDLogInfo(request)
            }
            .validationWithSP2Error(decoder: decoder)
            .publishDecodable(type: T.ResponseType.self, decoder: decoder)
            .value()
            .handleEvents(receiveSubscription: { subscription in
                self.delegate?.willReceiveSubscription(subscribe: subscription)
            }, receiveOutput: { output in
                self.delegate?.willReceiveOutput(output: output)
            }, receiveCompletion: { completion in
                self.delegate?.willReceiveCompletion(completion: completion)
            }, receiveCancel: {
                self.delegate?.willReceiveCancel()
            }, receiveRequest: { request in
                self.delegate?.willReceiveRequest(request: request)
            })
            .mapToSP2Error(delegate: self.delegate)
            .eraseToAnyPublisher()
    }
}

public extension RequestType {
    var baseURL: URL {
        URL(unsafeString: "https://salmon-stats-api.yuki.games/api/")
    }
}
