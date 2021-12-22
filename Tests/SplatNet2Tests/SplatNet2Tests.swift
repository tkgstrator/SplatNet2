import Combine
import Foundation
import KeychainAccess
@testable import SplatNet2
import XCTest

internal final class SplatNet2Tests: XCTestCase {
    private struct Configuration: Codable {
        let sessionTokenCode: String
        let sessionToken: String
        let splatoonToken: String
        let hash: Token
        let f: Token
        let iksmSession: String

        struct Token: Codable {
            let app: String
            let nso: String
        }
    }

    private let manager = SplatNet2(version: "1.13.2", userAgent: "Salmonia3/@tkgling")

    private let configuration: Configuration? = {
        let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()
        guard let url: URL = Bundle.module.url(forResource: "config", withExtension: "json") else {
            return nil
        }
        guard let data: Data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? decoder.decode(Configuration.self, from: data)
    }()

    func testBundleModule() throws {
        if let configuration = configuration {
            let sessionToken = configuration.sessionToken
            let request = AccessToken(sessionToken: sessionToken)
            let recorder = manager.publish(request).record()
            let elements = try wait(for: recorder.elements, timeout: 5)
        } else {
        }
    }
//    static var allTests = [
//        ("OAUTH", testOAuthURL),
//        ("SESSION TOKEN", testSessionToken),
//        ("ACCESS TOKEN", testAccessToken),
//        ("SPLATOON TOKEN", testSplatoonToken),
//        ("SPLATOON ACCESS TOKEN", testSplatoonAccessToken),
//        ("IKSM SESSION", testIksmSession1),
//        ("IKSM SESSION", testIksmSession2),
//        ("COOP RESULT", testGetResult),
//    ]
}

extension String {
    func queryValue(forKey: String) -> String? {
        let url = URL(unsafeString: self.replacingOccurrences(of: "#", with: "?"))
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        return queryItems?.filter { $0.name == forKey }.compactMap { $0.value }.first
    }
}
