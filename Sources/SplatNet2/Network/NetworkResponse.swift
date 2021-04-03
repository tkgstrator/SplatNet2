import Foundation

public class APIResponse: Decodable {
    public struct ErrorData: Decodable {
        var error: String
        // var errorDescription: String
        // var status: Int
        // var errorMessage: String
        // var correlationId: String
    }

    public struct SessionToken: Decodable {
        var sessionToken: String
    }

    public struct AccessToken: Decodable {
        var accessToken: String
        var expiresIn: Int
        var idToken: String
        var scope: [String]
        var tokenType: String
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
        var result: SplatoonTokenResult
        var status: Int
        var correlationId: String

        struct SplatoonTokenResult: Decodable {
            var webApiServerCredential: WebAPIServerCredential
            var user: WebAPIServerUser
            var firebaseCredential: FirebaseCredential
        }

        struct WebAPIServerUser: Decodable {
            var name: String
            var imageUri: String
            var id: Int
            var supportId: String
            var membership: Membership
        }

        struct Membership: Decodable {
            var active: Bool
        }

        struct FirebaseCredential: Decodable {
            var expiresIn: Int
            var accessToken: String
        }

        struct WebAPIServerCredential: Decodable {
            var expiresIn: Int
            var accessToken: String
        }
    }

    public struct SplatoonAccessToken: Decodable {
        var correlationId: String
        var result: AccessToken
        var status: Int

        struct AccessToken: Decodable {
            var accessToken: String
            var expiresIn: Int
        }
    }

    public struct IksmSession: Decodable {
        var iksmSession: String
        var nsaid: String

    }

    public struct ResultCoop: Decodable {
        var jobId: Int
        var jobScore: Int
        var jobRate: Int
        var jobResult: JobResult
        var schedule: Schedule
        var kumaPoint: Int
        var grade: Grade
        var gradePoint: Int
        var gradePointDelta: Int
        var startTime: Int
        var playTime: Int
        var endTime: Int
        var waveDetails: [WaveResult]
        var dangerRate: Double
        var bossCounts: [String: BossSalmonid]
        // var bossKillCounts: [String: BossSalmonid]
        var otherResults: [PlayerResult]
        var myResult: PlayerResult

        public struct JobResult: Decodable {
            var failureReason: String?
            var failureWave: Int?
            var isClear: Bool
        }

        public struct Schedule: Decodable {
            var stage: Stage
            var startTime: Int
            var endTime: Int
            var weapons: [WeaponList]
        }

        public struct Grade: Decodable {
            var id: String
            var longName: String
            var name: String
            var shortName: String
        }

        public struct Stage: Decodable {
            var image: String
            var name: String
        }

        public struct WaveResult: Decodable {
            var eventType: KeyName
            var waterLevel: KeyName
            var goldenIkuraNum: Int
            var goldenIkuraPopNum: Int
            var quotaNum: Int
            var ikuraNum: Int
        }

        struct KeyName: Decodable {
            var key: String
            var name: String
        }

        struct BossSalmonid: Decodable {
            var boss: KeyName
            var count: Int
        }

        public struct PlayerResult: Decodable {
            var bossKillCounts: [String: BossSalmonid]
            var deadCount: Int
            var helpCount: Int
            var ikuraNum: Int
            var goldenIkuraNum: Int
            var special: Special
            var specialCounts: [Int]
            var weaponList: [WeaponList]
            var playerType: PlayerType
            var name: String
            var pid: String
        }

        struct Special: IdName, Decodable {
            var id: String
            var name: String
        }

        struct WeaponList: Decodable {
            var id: String
            var weapon: Weapon
        }

        struct Weapon: IdName, Decodable {
            var id: String
            var name: String
            var image: String
            var thumbnail: String
        }

        struct PlayerType: Decodable {
            var species: String
            var style: String
        }
    }
}

protocol IdName: Decodable {
    var id: String { get }
    var name: String { get }
}

protocol KeyName: Decodable {
    var key: String { get }
    var name: String { get }
}
