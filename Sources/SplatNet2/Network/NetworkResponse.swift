import Foundation

public class APIResponse: Decodable {
    public struct ErrorData: Decodable {
        var error: String
        var errorDescription: String
    }

    public struct SessionToken: Decodable {
        var sessionToken: String
    }

    public struct AccessToken: Decodable {
        var accessToken: String
    }

    public struct S2SHash: Decodable {
        var hash: String
    }

    public struct FlapgAPI: Decodable {
        var result: FlapgParameters

        struct FlapgParameters: Decodable {
            var f: String
            var p1: String
            var p2: String
            var p3: String
        }
    }

    public struct SplatoonToken: Decodable {
        var result: WebAPIServerCredential
        var user: WebAPIServerUser

        struct WebAPIServerCredential: Decodable {
            var accessToken: String
        }

        struct WebAPIServerUser: Decodable {
            var name: String
            var imageUri: String
        }
    }

    public struct SplatoonAccessToken: Decodable {
        var result: AccessToken
    }

    public struct IksmSession: Decodable {

    }

    public struct ResultCoop: Decodable {
        var jobId: Int
        var stageId: Int
        var jobScore: Int
        var jobRate: Int
        var jobResult: JobResult
        var schedule: Schedule
        var kumaPoint: Int
        var grade: Int
        var gradePoint: Int
        var gradePointDelta: Int
        var startTime: String
        var playTime: String
        var endTime: String
        var waveDetails: [WaveResult]
        var dangerRate: Double
        var bossCounts: [Int]
        var bossKillCounts: [Int]
        var otherResults: [PlayerResult]
        var myResults: PlayerResult

        public struct JobResult: Decodable {
            var failureReason: String?
            var failureWave: Int?
            var isClear: Bool
        }

        public struct Schedule: Decodable {
            var stageId: Int
            var startTime: String
            var endTime: String
        }

        public struct WaveResult: Decodable {
            var eventType: String
            var waterLevel: String
            var goldenIkuraNum: Int
            var goldenIkuraPopNum: Int
            var quotaNum: Int
            var ikuraNum: Int
        }

        public struct PlayerResult: Decodable {
            var bossKillCounts: [Int]
            var deadCount: Int
            var helpCount: Int
            var ikuraNum: Int
            var goldenIkuraNum: Int
            var specialId: Int
            var specialCounts: [Int]
            var weaponLists: [Int]
            var name: String
            var pid: String
        }
    }
}
