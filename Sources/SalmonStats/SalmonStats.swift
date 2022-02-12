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
        guard let nsaid = account?.credential.nsaid else {
            return Fail(outputType: [Metadata.Response].self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        let request = Metadata(nsaid: nsaid)
        return publish(request)
    }

    public func getCoopResultFromSalmonStats(resultId: Int) -> AnyPublisher<CoopResult.Response, SP2Error> {
        guard let nsaid = account?.credential.nsaid else {
            return Fail(outputType: CoopResult.Response.self, failure: SP2Error.credentialFailed)
                .eraseToAnyPublisher()
        }
        let request = StatsResult(resultId: resultId)
        return publish(request)
            .map({ CoopResult.Response(from: $0, playerId: nsaid) })
            .eraseToAnyPublisher()
    }

    private func uploadResults(result: CoopResult.Response) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error> {
        uploadResults(results: [result])
    }

    private func uploadResults(results: [CoopResult.Response]) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error> {
        results.chunked(by: 10)
            .map({ UploadResult(results: $0) })
            .publisher
            .flatMap({ [self] in publish($0) })
            .collect()
            .map({ zip($0.flatMap({ $0 }), results).compactMap({ ($0.0, $0.1) }) })
            .eraseToAnyPublisher()
    }

    public func uploadResult(resultId: Int) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error> {
        getCoopResult(resultId: resultId)
            .flatMap({ [self] in uploadResults(result: $0) })
            .eraseToAnyPublisher()
    }

//    private func uploadResults(resultId: Int? = nil) -> AnyPublisher<[(UploadResult.Response, CoopResult.Response)], SP2Error> {
//        getCoopResults(resultId: resultId)
//            .flatMap({ [self] in uploadResults(results: $0) })
//            .eraseToAnyPublisher()
//    }

    public func uploadResults(resultId: Int? = nil) {
        getCoopResults(resultId: resultId)
            .flatMap({ [self] in uploadResults(results: $0) })
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { [self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    delegate?.failedWithSP2Error(error: error)
                }
            }, receiveValue: { [self] response in
                let results = response.map({ (id: $0.0.salmonId, status: $0.0.created ? UploadStatus.success : UploadStatus.failure, result: $0.1 ) })
                if let delegate = delegate as? SalmonStatsSessionDelegate {
                    delegate.didFinishLoadResultsFromSplatNet2(results: results)
                }
            })
            .store(in: &task)
    }
//    public func getCoopResultsFromSalmonStats(from: Int, to: Int) -> AnyPublisher<[CoopResult.Response], SP2Error> {
//        guard let nsaid = account?.credential.nsaid else {
//            return Fail(outputType: [CoopResult.Response].self, failure: SP2Error.credentialFailed)
//                .eraseToAnyPublisher()
//        }
//        [from ... to].publisher
//            .flatMap({ publish(StatsResults(nsaid: nsaid, pageId: $0, count: 50)) })
//            .collect()
//            .eraseToAnyPublisher()
//    }

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
            .mapToSP2Error()
            .eraseToAnyPublisher()
    }
}

public extension RequestType {
    var baseURL: URL {
        URL(unsafeString: "https://salmon-stats-api.yuki.games/api/")
    }
}

public extension Publisher {
    /// AFError -> SP2Error
    func mapToSP2Error() -> Publishers.MapError<Self, SP2Error> {
        mapError({ error -> SP2Error in
            DDLogError(error)
            guard let sp2Error = error.asSP2Error else {
                return SP2Error.requestAdaptionFailed
            }
            return sp2Error
        })
    }

    func result(delegate: SalmonStatsSessionDelegate?) -> AnyCancellable where Output == [(UploadResult.Response, CoopResult.Response)] {
        mapToSP2Error()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    delegate?.failedWithSP2Error(error: error)
                }
            }, receiveValue: { response in
                let results = response.map({ (id: $0.0.salmonId, status: $0.0.created ? UploadStatus.success : UploadStatus.failure, result: $0.1 ) })
                delegate?.didFinishLoadResultsFromSplatNet2(results: results)
            })
    }
}
