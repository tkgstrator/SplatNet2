import XCTest
@testable import SplatNet2
@testable import SwiftyJSON

final class SplatNet2Tests: XCTestCase {
    func testIksmSession() {
//        let session_token = "eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MDA3MjkzMTQsInR5cCI6InNlc3Npb25fdG9rZW4iLCJleHAiOjE2NjM4MDEzMTQsImp0aSI6IjM2MDY2NDcwNTEiLCJhdWQiOiI3MWI5NjNjMWI3YjZkMTE5Iiwic3ViIjoiNWFlOGY3YTc4YjBjY2E0ZCIsInN0OnNjcCI6WzAsOCw5LDE3LDIzXSwiaXNzIjoiaHR0cHM6Ly9hY2NvdW50cy5uaW50ZW5kby5jb20ifQ._DKXEhT0cnbbdmWdBTiodqmbliVaWja_FL6gSgSIfPo"
//        let session_token_code = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3MWI5NjNjMWI3YjZkMTE5Iiwic3RjOnNjcCI6WzAsOCw5LDE3LDIzXSwianRpIjoiMjY2MjMwMjk3MzciLCJ0eXAiOiJzZXNzaW9uX3Rva2VuX2NvZGUiLCJleHAiOjE2MDIwNjkzNTgsInN1YiI6IjVhZThmN2E3OGIwY2NhNGQiLCJpc3MiOiJodHRwczovL2FjY291bnRzLm5pbnRlbmRvLmNvbSIsInN0YzpjIjoiOFBsSm9yYnFjMW9VbXluamd0SUNEM0p6ck5kM29lejlrVGVFWUJDc1hscyIsInN0YzptIjoiUzI1NiIsImlhdCI6MTYwMjA2ODc1OH0.xOmko8x8LNNVRzB-OnOsEwCg04jE-6gL5lj0hy3Tzl4"
//        let session_token_code_verifier = "1Z67BfUuhHK8kk9SQxre81Ffx2_4Kzz42mAUUI0Ir5g"
        do {
//            var response: JSON = JSON()
//            let version = "1.9.0"
//            response = try SplatNet2.getAccessToken(session_token)
//            let access_token = response["access_token"].stringValue
//            print("ACCESS TOKEN", access_token)
//            response = try SplatNet2.callFlapgAPI(access_token, "nso")
//            let flapg_nso = response["result"]
//            print("FLAPG NSO", flapg_nso)
//            response = try SplatNet2.getSplatoonToken(flapg_nso, version: version)
//            let username = response["result"]["user"]["name"].stringValue
//            let imageUri = response["result"]["user"]["imageUri"].stringValue
//            print(username, imageUri)
//            let splatoon_token = response["result"]["webApiServerCredential"]["accessToken"].stringValue
//            print("SPLATOON TOKEN", splatoon_token)
//            response = try SplatNet2.callFlapgAPI(splatoon_token, "app")
//            let flapg_app = response["result"]
//            print("FLAPG APP", flapg_app)
//            response = try SplatNet2.getSplatoonAccessToken(flapg_app, splatoon_token)
//            let splatoon_access_token = response["result"]["accessToken"].stringValue
//            print("SPLATOON ACCESS TOKEN", splatoon_access_token)
//            response = try SplatNet2.getIksmSession(splatoon_access_token)
//            let iksm_session = response["iksm_session"].stringValue
//            print("IKSM SESSION", iksm_session as Any)
//            response = try SplatNet2.getSummary(iksm_session: iksm_session)
//            let job_num: Int = response["summary"]["card"]["job_num"].intValue
//            response = try SplatNet2.getResult(job_id: job_num, iksm_session: iksm_session)
//            XCTAssert(SplatNet2.isValid(iksm_session: iksm_session))
//            print("VALIDATION", SplatNet2.isValid(iksm_session: iksm_session))
//            response = try SplatNet2.genIksmSession(session_token, version: version)
//            print(response)
            let iksm_session = "f686c6c3cca76704b45f10a70835c716b2be1d92"
            let nsaid = try SplatNet2.getPlayerId(iksm_session)
            print(iksm_session, nsaid)
        } catch {
            XCTFail()
            print(error)
            print(error.localizedDescription)
        }
    }
//
    func testNickName() {
        let nsaids: [String] = ["55f850dd60952002", "1a6c2d45dd7a4d91", "eadb38dda8abdc09", "55f850dd60952002", "1a6c2d45dd7a4d91", "228e1ab68a02a306", "1a6c2d45dd7a4d91", "55f850dd60952002", "701f07f4f86556c0", "1a6c2d45dd7a4d91", "55f850dd60952002", "701f07f4f86556c0", "1a6c2d45dd7a4d91", "55f850dd60952002", "701f07f4f86556c0"]
        do {
            try SplatNet2.getPlayerNickName(nsaids, iksm_session: "737f02b4bff49ab9f6b1a3f2c5503592f0cc6df0")
        } catch {
            XCTFail()
            print(error, error.localizedDescription)
        }
    }
    
    
    
    static var allTests = [
        ("IKSM SESSION", testIksmSession),
        ("NICK NAME", testNickName),
    ]
}
