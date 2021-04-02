import XCTest
import Combine
import CombineExpectations
import Foundation
@testable import SplatNet2

final class SplatNet2Tests: XCTestCase {
    let redirectURL = "npf71b963c1b7b6d119://auth#session_state=697c722e7694131d6f0110ab61d77523b3bcd3518a4fcd3e29a75fc93121bca2&session_token_code=eyJhbGciOiJIUzI1NiJ9.eyJzdGM6c2NwIjpbMCw4LDksMTcsMjNdLCJzdWIiOiI1YWU4ZjdhNzhiMGNjYTRkIiwiYXVkIjoiNzFiOTYzYzFiN2I2ZDExOSIsInR5cCI6InNlc3Npb25fdG9rZW5fY29kZSIsImp0aSI6IjM0NjU4NjA0NTkxIiwiZXhwIjoxNjE3MzgwNjk1LCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsInN0YzptIjoiUzI1NiIsImlhdCI6MTYxNzM4MDA5NSwic3RjOmMiOiJVTEt5QjctWWwwZWNkcnh1RGR4YkpOYUlPY0pQSk9zaW51Z3ZXN1h3dXNRIn0._tSq0YBmH9Sh6yCuTM1qGZEgC_EPPmiXDi21KU8Ir3M&state=v1MguHzdCzhY7W7DMciwfFGPbzV0qdukFOnPX6czsT7m2END726qGJRrScHUT5AmZ2oS7RArsVj2z4eDH4BqThJpvQv7rgLIrHSOzp4NtwS3kFG3kIOqSE4vHCDUYE0X"
    let sessionToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MTczODAxMTIsImp0aSI6IjQ4Njk4NjAwMjIiLCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkiLCJleHAiOjE2ODA0NTIxMTIsInR5cCI6InNlc3Npb25fdG9rZW4iLCJzdDpzY3AiOlswLDgsOSwxNywyM10sInN1YiI6IjVhZThmN2E3OGIwY2NhNGQifQ.KD0a5NaQnVB6Ct3cV1DiCx_ULBmXbxIGZf8EIK6_JT4"
    let accessToken: String = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdmODlmZjk5LTdkZDAtNDdjZS1iOWVlLTgxZWQ4YzVkMjEyZCIsImprdSI6Imh0dHBzOi8vYWNjb3VudHMubmludGVuZG8uY29tLzEuMC4wL2NlcnRpZmljYXRlcyJ9.eyJhYzpzY3AiOlswLDgsOSwxNywyM10sImlhdCI6MTYxNzM4NjI1NCwiZXhwIjoxNjE3Mzg3MTU0LCJzdWIiOiI1YWU4ZjdhNzhiMGNjYTRkIiwidHlwIjoidG9rZW4iLCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkiLCJhYzpncnQiOjY0LCJqdGkiOiIzMGU0OGU3Yy1iMWNhLTQxYTEtODFiMi04NDZmMGYwMTI0ZGIifQ.k-Hozdb4yPrF7UM7BdCh7bJdT9VHPXw_0LbAbltHuC5pL5R0TVHvK0KD-wd76cpKwq8kameg3VdHAxFtZ_GN4TrisdutHsLh6G2ax9xMEqIWie1qjPd6c8Y-NhBQ5qI3grV-SpF1aaxXAc_IQnEWfp3heVxq5oLYl29q9ZNd-3c-hIZSZJ-hklJfulAkjQAm_sIfqQb7w-KDXWxAqURpqdFMBIpyfsn3u806EpxcXmAh3CaKBpezAiSddMejqz4giYSIq978qflbricvhTVNCxTDbmRrFbjmblJY9MeGL-G4sEPFfS-CnsCvYYsMjlV_jWFQ43hb1ls3n-4KsZ4lXQ"
    let splatoonToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjQ3MzczNjA4MzEzODE1MDQsImlhdCI6MTYxNzM4NjI4MCwidHlwIjoiaWRfdG9rZW4iLCJtZW1iZXJzaGlwIjp7ImFjdGl2ZSI6dHJ1ZX0sImlzcyI6ImFwaS1scDEuem5jLnNydi5uaW50ZW5kby5uZXQiLCJhdWQiOiJmNDE3ZTF0aWJqcWQ5MWNoOTl1NDlpd3o1c245Y2h5MyIsImV4cCI6MTYxNzM5MzQ4MH0.YJiRG4DFCoPZGi8XRCZqFc8JDzfuw8RAYj3d0RTRA_c"
    
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
    
    func testSplatoonAccessToken() {
        do {
            let task = NetworkManager.shared.getSplatoonAccessToken(splatoonToken: splatoonToken)
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
        ("SPLATOON ACCESS TOKEN", testSplatoonAccessToken),
    ]
}

extension String {
    func queryValue(forKey: String) -> String? {
        let url: URL = URL(string: self.replacingOccurrences(of: "#", with: "?"))!
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        return queryItems?.filter { $0.name == forKey }.compactMap { $0.value }.first
    }
    
}
