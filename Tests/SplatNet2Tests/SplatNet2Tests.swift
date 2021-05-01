import XCTest
import Combine
import CombineExpectations
import Foundation
@testable import SplatNet2

final class SplatNet2Tests: XCTestCase {
    let redirectURL = "npf71b963c1b7b6d119://auth#session_state=697c722e7694131d6f0110ab61d77523b3bcd3518a4fcd3e29a75fc93121bca2&session_token_code=eyJhbGciOiJIUzI1NiJ9.eyJzdGM6c2NwIjpbMCw4LDksMTcsMjNdLCJzdWIiOiI1YWU4ZjdhNzhiMGNjYTRkIiwiYXVkIjoiNzFiOTYzYzFiN2I2ZDExOSIsInR5cCI6InNlc3Npb25fdG9rZW5fY29kZSIsImp0aSI6IjM0NjU4NjA0NTkxIiwiZXhwIjoxNjE3MzgwNjk1LCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsInN0YzptIjoiUzI1NiIsImlhdCI6MTYxNzM4MDA5NSwic3RjOmMiOiJVTEt5QjctWWwwZWNkcnh1RGR4YkpOYUlPY0pQSk9zaW51Z3ZXN1h3dXNRIn0._tSq0YBmH9Sh6yCuTM1qGZEgC_EPPmiXDi21KU8Ir3M&state=v1MguHzdCzhY7W7DMciwfFGPbzV0qdukFOnPX6czsT7m2END726qGJRrScHUT5AmZ2oS7RArsVj2z4eDH4BqThJpvQv7rgLIrHSOzp4NtwS3kFG3kIOqSE4vHCDUYE0X"
    let sessionToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MTczODAxMTIsImp0aSI6IjQ4Njk4NjAwMjIiLCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkiLCJleHAiOjE2ODA0NTIxMTIsInR5cCI6InNlc3Npb25fdG9rZW4iLCJzdDpzY3AiOlswLDgsOSwxNywyM10sInN1YiI6IjVhZThmN2E3OGIwY2NhNGQifQ.KD0a5NaQnVB6Ct3cV1DiCx_ULBmXbxIGZf8EIK6_JT4"
    let accessToken: String = "eyJqa3UiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbS8xLjAuMC9jZXJ0aWZpY2F0ZXMiLCJhbGciOiJSUzI1NiIsImtpZCI6IjdmODlmZjk5LTdkZDAtNDdjZS1iOWVlLTgxZWQ4YzVkMjEyZCJ9.eyJhYzpzY3AiOlswLDgsOSwxNywyM10sImFjOmdydCI6NjQsImlzcyI6Imh0dHBzOi8vYWNjb3VudHMubmludGVuZG8uY29tIiwiZXhwIjoxNjE3Mzk1MzcxLCJ0eXAiOiJ0b2tlbiIsImp0aSI6IjRlODBiNmZjLWEwZjQtNGY3My1hZDQxLTZkYWMxODdhZjY3ZSIsInN1YiI6IjVhZThmN2E3OGIwY2NhNGQiLCJpYXQiOjE2MTczOTQ0NzEsImF1ZCI6IjcxYjk2M2MxYjdiNmQxMTkifQ.R0OVDTgTPg0RdKmD5ZEe9SAWVgHf2s3iTR_9uOPEtvWzsomOJSTI1SoSh2W7z-B6-9RsfJT0aqopJHrW2obnLlpdb6i4JrVU0nW7CRIj_59I1QrN-YbDpaEI4uQCiGVrwoyaWqv5u1FwS1ZlSEaDiRExET_4fST4G_YfyYC35oUGt36LBg_xLVCbV0zwDaa2kK-xp6wMM04XYO2rv2vb9K6U8TDPe7egBhcbKepfwEP4wzMFWGiGC61gmMvlMXdheuEEPYBxPFqyifap-eX20K4wfKRfeWR09s1TF8ZjvlEReCk5GQmPwg8VydQmOfRk1GWnrDl01OgRb9bNPUhGvA"
    let splatoonToken: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcGktbHAxLnpuYy5zcnYubmludGVuZG8ubmV0IiwibWVtYmVyc2hpcCI6eyJhY3RpdmUiOnRydWV9LCJhdWQiOiJmNDE3ZTF0aWJqcWQ5MWNoOTl1NDlpd3o1c245Y2h5MyIsImlhdCI6MTYxNzM5MzAwNCwic3ViIjo0NzM3MzYwODMxMzgxNTA0LCJleHAiOjE2MTc0MDAyMDQsInR5cCI6ImlkX3Rva2VuIn0.mB-shjb8MpYLN-PtnxErDvQ_FJ-3V6LFyZdOe1TPIs4"
    let splatoonAccessToken: String = "eyJ0eXAiOiJKV1QiLCJraWQiOiJXOVVEdEYwZzB6dTdtNVZGbzVZOUpiYm9MMU0iLCJhbGciOiJSUzI1NiIsImprdSI6Imh0dHBzOi8vYXBpLWxwMS56bmMuc3J2Lm5pbnRlbmRvLm5ldC92MS9XZWJTZXJ2aWNlL0NlcnRpZmljYXRlL0xpc3QifQ.eyJsaW5rcyI6eyJuZXR3b3JrU2VydmljZUFjY291bnQiOnsiaWQiOiIzZjg5YzM3OTFjNDNlYTU3In19LCJhdWQiOiI1dm8yaTJrbXp4NnBzMWwxdmpzamduanM5OXltemN3MCIsImV4cCI6MTYxNzQwMDIyOSwidHlwIjoiaWRfdG9rZW4iLCJzdWIiOjQ3MzczNjA4MzEzODE1MDQsImlzcyI6ImFwaS1scDEuem5jLnNydi5uaW50ZW5kby5uZXQiLCJqdGkiOiJiYzQxNWM1NC0zYThhLTRmYjgtYmE5OC04ZDRmNDY1MTkwNjQiLCJtZW1iZXJzaGlwIjp7ImFjdGl2ZSI6dHJ1ZX0sImlhdCI6MTYxNzM5MzAyOX0.BrMrKBC6-uzeWeb0LNQ6jkafewrY9ozl5ydRhILpxHKH6bW_vJ-ASAYRIaWTxt8wwdktsvLpq5HQuh8-WE-fHe2UXEqy7aDe5Tfpv0inYKXM4fWti6c0uO9hZYeQIT6fOX9_UyEAJs4lEIcX1ys6YuecOqgvfcVFjvAvOfZh-edtrzwAl54s4qFdJy4daQEav5MSmKwhLeeg9in8JvdRVEgAPaKvnn5cgepTXI90SbK6Xv3gykpGvvK9sF4LGAibQsgd1grlpZo5tPIdnigEyOTdPqdNE5XeHI-kPTtNvtrJ0fbGv6XV70fka-eKoYRkGsylZ3dd6PK5T_2Q-jEKsA"
    let iksmSession: String = "258cd5b2106ce013d1686c1806b09b411a1cf397"
    
    func testOAuthURL() {
        let splatnet2 = SplatNet2()
        print(splatnet2.oauthURL)
    }
    
//    func testSessionToken() {
//        do {
//            guard let sessionTokenCode = redirectURL.queryValue(forKey: "session_token_code") else { throw APIError.response }
//            let task = SplatNet2.shared.getSessionToken(sessionTokenCode: sessionTokenCode)
//            let recorder = task.record()
//            let elements = try wait(for: recorder.elements, timeout: 10)
//            print(elements)
//        } catch {
//            XCTFail()
//        }
//    }
//
    func testAccessToken() {
        do {
            let task = SplatNet2.shared.getAccessToken(sessionToken: sessionToken)
            let recorder = task.record()
            let elements = try wait(for: recorder.elements, timeout: 10)
            print(elements)
        } catch {
            XCTFail()
        }
    }
//
//    func testSplatoonToken() {
//        do {
//            let task = SplatNet2.shared.getSplatoonToken(accessToken: accessToken)
//            let recorder = task.record()
//            let elements = try wait(for: recorder.elements, timeout: 10)
//            print(elements)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func testSplatoonAccessToken() {
//        do {
//            let task = SplatNet2.shared.getSplatoonAccessToken(splatoonToken: splatoonToken)
//            let recorder = task.record()
//            let elements = try wait(for: recorder.elements, timeout: 10)
//            print(elements)
//        } catch {
//            XCTFail()
//        }
//    }
//
//    func testIksmSession1() {
//        do {
//            let task = SplatNet2.shared.getIksmSession(accessToken: splatoonAccessToken)
//            let recorder = task.record()
//            let elements = try wait(for: recorder.elements, timeout: 10)
//            print(elements)
//        } catch {
//            XCTFail()
//        }
//    }
    
    func testIksmSession2() {
        do {
            let splatnet2 = SplatNet2()
            let task = splatnet2.getCookie(sessionToken: sessionToken, version: "1.10.1")
            let recorder = task.record()
            let elements = try wait(for: recorder.elements, timeout: 10)
            print(elements)
        } catch {
            XCTFail()
        }
    }
    
    func testGetResultCoop() {
        do {
            let iksmSession: String = "258cd5b2106ce013d1686c1806b09b411a1cf398"
            let splatnet2 = SplatNet2(iksmSession: iksmSession, sessionToken: sessionToken, version: "1.10.1")
            let task = splatnet2.getResultCoop(jobId: 3549)
            let recorder = task.record()
            let elements = try wait(for: recorder.elements, timeout: 15)
            print(elements)
        } catch {
            XCTFail()
        }
    }

    static var allTests = [
        ("OAUTH", testOAuthURL),
//        ("SESSION TOKEN", testSessionToken),
//        ("ACCESS TOKEN", testAccessToken),
//        ("SPLATOON TOKEN", testSplatoonToken),
//        ("SPLATOON ACCESS TOKEN", testSplatoonAccessToken),
//        ("IKSM SESSION", testIksmSession1),
        ("IKSM SESSION", testIksmSession2),
        ("COOP RESULT", testGetResultCoop),
    ]
}

extension String {
    func queryValue(forKey: String) -> String? {
        let url: URL = URL(string: self.replacingOccurrences(of: "#", with: "?"))!
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        return queryItems?.filter { $0.name == forKey }.compactMap { $0.value }.first
    }
    
}
