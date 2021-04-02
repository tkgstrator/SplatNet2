import XCTest
import Combine
import CombineExpectations
import Foundation
@testable import SplatNet2

final class SplatNet2Tests: XCTestCase {
    let redirectURL = "npf71b963c1b7b6d119://auth#session_state=697c722e7694131d6f0110ab61d77523b3bcd3518a4fcd3e29a75fc93121bca2&session_token_code=eyJhbGciOiJIUzI1NiJ9.eyJzdGM6c2NwIjpbMCw4LDksMTcsMjNdLCJzdWIiOiI1YWU4ZjdhNzhiMGNjYTRkIiwiYXVkIjoiNzFiOTYzYzFiN2I2ZDExOSIsInR5cCI6InNlc3Npb25fdG9rZW5fY29kZSIsImp0aSI6IjM0NjU4NjA0NTkxIiwiZXhwIjoxNjE3MzgwNjk1LCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsInN0YzptIjoiUzI1NiIsImlhdCI6MTYxNzM4MDA5NSwic3RjOmMiOiJVTEt5QjctWWwwZWNkcnh1RGR4YkpOYUlPY0pQSk9zaW51Z3ZXN1h3dXNRIn0._tSq0YBmH9Sh6yCuTM1qGZEgC_EPPmiXDi21KU8Ir3M&state=v1MguHzdCzhY7W7DMciwfFGPbzV0qdukFOnPX6czsT7m2END726qGJRrScHUT5AmZ2oS7RArsVj2z4eDH4BqThJpvQv7rgLIrHSOzp4NtwS3kFG3kIOqSE4vHCDUYE0X"
    let sessionToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MTczODAxMTIsImp0aSI6IjQ4Njk4NjAwMjIiLCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkiLCJleHAiOjE2ODA0NTIxMTIsInR5cCI6InNlc3Npb25fdG9rZW4iLCJzdDpzY3AiOlswLDgsOSwxNywyM10sInN1YiI6IjVhZThmN2E3OGIwY2NhNGQifQ.KD0a5NaQnVB6Ct3cV1DiCx_ULBmXbxIGZf8EIK6_JT4"
    
    func testOAuthURL() {
        print(NetworkManager.shared.oauthURL)
    }
    
    func testSessionToken() {
        do {
            guard let sessionTokenCode = redirectURL.queryValue(forKey: "session_token_code") else { throw APIError.response }
            let task = NetworkManager.shared.getSessionToken(sessionTokenCode: sessionTokenCode)
            let recorder = task.record()
            let elements = try wait(for: recorder.elements, timeout: 10)
            print(elements)
        } catch {
            XCTFail()
        }
    }
    
    func testAccessToken() {
        do {
            let task = NetworkManager.shared.getAccessToken(sessionToken: sessionToken)
            let recorder = task.record()
            let elements = try wait(for: recorder.elements, timeout: 10)
            print(elements)
        } catch {
            XCTFail()
        }
    }
    
    func testSplatoonToken() {
        do {
            let task = NetworkManager.shared.getAccessToken(sessionToken: sessionToken)
            let recorder = task.record()
            let elements = try wait(for: recorder.elements, timeout: 10)
            print(elements)
        } catch {
            XCTFail()
        }
    }
    
    static var allTests = [
        ("OAUTH", testOAuthURL),
        ("SESSION TOKEN", testSessionToken),
        ("SESSION TOKEN", testAccessToken),
    ]
}

extension String {
    func queryValue(forKey: String) -> String? {
        let url: URL = URL(string: self.replacingOccurrences(of: "#", with: "?"))!
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        return queryItems?.filter { $0.name == forKey }.compactMap { $0.value }.first
    }
    
}
