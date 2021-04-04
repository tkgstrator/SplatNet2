import Foundation
import Combine

extension SplatNet2 {
    // JSON取得
    func remote<Request: RequestProtocol>(request: Request) -> Future<Request.ResponseType, APIError> {
        NetworkPublisher.publish(request)
    }

    // IKSM SESSION取得
    func generate<Request: APIRequest.IksmSession>(request: Request) -> Future<APIResponse.IksmSession, APIError> {
        NetworkPublisher.generate(request)
    }
}
