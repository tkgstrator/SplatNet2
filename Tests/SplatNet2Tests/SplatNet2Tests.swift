import XCTest
import Combine
import CombineExpectations
import Foundation
@testable import SplatNet2

final class SplatNet2Tests: XCTestCase {
    let redirectURL = "npf71b963c1b7b6d119://auth#session_state=697c722e7694131d6f0110ab61d77523b3bcd3518a4fcd3e29a75fc93121bca2&session_token_code=eyJhbGciOiJIUzI1NiJ9.eyJzdGM6c2NwIjpbMCw4LDksMTcsMjNdLCJzdWIiOiI1YWU4ZjdhNzhiMGNjYTRkIiwiYXVkIjoiNzFiOTYzYzFiN2I2ZDExOSIsInR5cCI6InNlc3Npb25fdG9rZW5fY29kZSIsImp0aSI6IjM0NjU4NjA0NTkxIiwiZXhwIjoxNjE3MzgwNjk1LCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsInN0YzptIjoiUzI1NiIsImlhdCI6MTYxNzM4MDA5NSwic3RjOmMiOiJVTEt5QjctWWwwZWNkcnh1RGR4YkpOYUlPY0pQSk9zaW51Z3ZXN1h3dXNRIn0._tSq0YBmH9Sh6yCuTM1qGZEgC_EPPmiXDi21KU8Ir3M&state=v1MguHzdCzhY7W7DMciwfFGPbzV0qdukFOnPX6czsT7m2END726qGJRrScHUT5AmZ2oS7RArsVj2z4eDH4BqThJpvQv7rgLIrHSOzp4NtwS3kFG3kIOqSE4vHCDUYE0X"
    let sessionToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MTczODAxMTIsImp0aSI6IjQ4Njk4NjAwMjIiLCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkiLCJleHAiOjE2ODA0NTIxMTIsInR5cCI6InNlc3Npb25fdG9rZW4iLCJzdDpzY3AiOlswLDgsOSwxNywyM10sInN1YiI6IjVhZThmN2E3OGIwY2NhNGQifQ.KD0a5NaQnVB6Ct3cV1DiCx_ULBmXbxIGZf8EIK6_JT4"
    let accessToken: String = "eyJraWQiOiI3Zjg5ZmY5OS03ZGQwLTQ3Y2UtYjllZS04MWVkOGM1ZDIxMmQiLCJhbGciOiJSUzI1NiIsImprdSI6Imh0dHBzOi8vYWNjb3VudHMubmludGVuZG8uY29tLzEuMC4wL2NlcnRpZmljYXRlcyJ9.eyJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsImFjOmdydCI6NjQsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkiLCJhYzpzY3AiOlswLDgsOSwxNywyM10sImV4cCI6MTYxNzM4NTQ2OCwidHlwIjoidG9rZW4iLCJqdGkiOiI1M2EzNmE1NC0wNzMzLTRjZGItYjI5NS02NDE0NDhiNGFiZDUiLCJpYXQiOjE2MTczODQ1NjgsInN1YiI6IjVhZThmN2E3OGIwY2NhNGQifQ.XDUwVdCRlXW7r_eyO6bxur1YbN_5FxlAZ3jb6979d5axaS3J0l9pDw3sGwz0V1p-rdvVISBWZh_1Fn5gDPBfLKM3dsggvkYZIIT0CiGcJn7ReFlZ4aBO9OAltLHMQsaa2yjJXhgP_5J4sN_53vyT9lezYyPR4_ZR-zlLspLpIfyMMQZ_XdT9Dafe-_jUiJau6bAZf5cXVTkCV6ylasf_C5k2AzUsnKUI34Wa_dz-UDvWyH3gk5EAsSMrfDh0XBueJniw_bJ88yx8BxE73wc5DIRss2UhpJrc06eUdX2Be4U39CKa4D1MLFGuKKbL9QwGnV2ovz5t-si-NqMToK2MVA"
    
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
            let task = NetworkManager.shared.getSplatoonToken(accessToken: accessToken)
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
        ("ACCESS TOKEN", testAccessToken),
        ("SPLATOON TOKEN", testSplatoonToken),
    ]
}

extension String {
    func queryValue(forKey: String) -> String? {
        let url: URL = URL(string: self.replacingOccurrences(of: "#", with: "?"))!
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        return queryItems?.filter { $0.name == forKey }.compactMap { $0.value }.first
    }
    
}
