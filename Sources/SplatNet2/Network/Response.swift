import Foundation

public class Response: Codable {
    public struct ScheduleCoop: Codable {
        public var startTime: Int
        public var stageId: Int
        public var rareWeapon: Int
        public var endTime: Int
        public var weaponList: [Int]
    }
    
    public struct ServerError: Codable, Error, Identifiable {
        public var id: UUID { UUID() }
        var error: String?
        var errorDescription: String?
        var status: Int?
        var errorMessage: String?
        var correlationId: String?
        var message: String?            // https://app.splatoon2.nintendo.net/api
        var code: String?               // https://app.splatoon2.nintendo.net/api
    }
    
    public struct SessionToken: Codable {
        public var sessionToken: String
    }

    public struct AccessToken: Codable {
        var accessToken: String
        var expiresIn: Int
        var idToken: String
        var scope: [String]
        var tokenType: String
    }

    public struct S2SHash: Codable {
        var hash: String
    }

    public struct FlapgAPI: Codable {
        var result: FlapgParameters

        struct FlapgParameters: Codable {
            var f: String
            var p1: String
            var p2: String
            var p3: String
        }
    }

    public struct SplatoonToken: Codable {
        var result: SplatoonTokenResult
        var status: Int
        var correlationId: String

        struct SplatoonTokenResult: Codable {
            var webApiServerCredential: WebAPIServerCredential
            var user: WebAPIServerUser
            var firebaseCredential: FirebaseCredential
        }

        struct WebAPIServerUser: Codable {
            var name: String
            var imageUri: String
            var id: Int
            var supportId: String
            var membership: Membership
        }

        struct Membership: Codable {
            var active: Bool
        }

        struct FirebaseCredential: Codable {
            var expiresIn: Int
            var accessToken: String
        }

        struct WebAPIServerCredential: Codable {
            var expiresIn: Int
            var accessToken: String
        }
    }

    public struct SplatoonAccessToken: Codable {
        var correlationId: String
        var result: AccessToken
        var status: Int

        struct AccessToken: Codable {
            var accessToken: String
            var expiresIn: Int
        }
    }

    public struct IksmSession: Codable {
        var iksmSession: String
        var nsaid: String
    }

    public struct UserInfo: Codable {
        public var iksmSession: String
        public var nsaid: String
        public var nickname: String
        public var membership: Bool
        public var imageUri: String
        public var expiresIn: String
        public var sessionToken: String

        init(iksmSession: String, sessionToken: String, nsaid: String, nickname: String, membership: Bool, imageUri: String, expiresIn: Int) {
            self.iksmSession = iksmSession
            self.sessionToken = sessionToken
            self.nsaid = nsaid
            self.membership = membership
            self.imageUri = imageUri
            self.nickname = nickname
            let formatter: ISO8601DateFormatter = {
                let formatter = ISO8601DateFormatter()
                formatter.timeZone = TimeZone.current
                return formatter
            }()
            self.expiresIn = formatter.string(from: Date(timeIntervalSince1970: Date().timeIntervalSince1970 + TimeInterval(expiresIn)))
        }
    }

    public struct ResultCoop: Codable {
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
        var otherResults: [PlayerResult]
        var myResult: PlayerResult

        public struct JobResult: Codable {
            var failureReason: String?
            var failureWave: Int?
            var isClear: Bool
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(failureReason, forKey: .failureReason)
                try container.encode(failureWave, forKey: .failureWave)
                try container.encode(isClear, forKey: .isClear)
            }
        }

        public struct Schedule: Codable {
            var stage: Stage
            var startTime: Int
            var endTime: Int
            var weapons: [WeaponList]
        }

        public struct Grade: Codable {
            var id: String
            var longName: String
            var name: String
            var shortName: String
        }

        public struct Stage: Codable {
            var image: String
            var name: String
            var stageId: Int {
                get {
                    switch image {
                    case "/images/coop_stage/65c68c6f0641cc5654434b78a6f10b0ad32ccdee.png":
                        return 5000
                    case "/images/coop_stage/e07d73b7d9f0c64e552b34a2e6c29b8564c63388.png":
                        return 5001
                    case "/images/coop_stage/6d68f5baa75f3a94e5e9bfb89b82e7377e3ecd2c.png":
                        return 5002
                    case "/images/coop_stage/e9f7c7b35e6d46778cd3cbc0d89bd7e1bc3be493.png":
                        return 5003
                    case "/images/coop_stage/50064ec6e97aac91e70df5fc2cfecf61ad8615fd.png":
                        return 5004
                    default:
                        return 5000
                    }
                }
            }
        }

        public struct WaveResult: Codable {
            var eventType: KeyName
            var waterLevel: KeyName
            var goldenIkuraNum: Int
            var goldenIkuraPopNum: Int
            var quotaNum: Int
            var ikuraNum: Int
        }

        struct KeyName: Codable {
            var key: String
            var name: String
        }

        struct BossSalmonid: Codable {
            var boss: KeyName
            var count: Int
        }

        public struct PlayerResult: Codable {
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

        struct Special: IdName, Codable {
            var id: String
            var name: String
        }

        struct WeaponList: Codable {
            var id: String
            var weapon: Weapon?
            var coopSpecialWeapon: CoopWeapon?
        }

        struct Weapon: IdName, Codable {
            var id: String
            var name: String
            var image: String
            var thumbnail: String
        }
        
        struct CoopWeapon: Codable {
            var image: String
            var name: String
        }

        struct PlayerType: Codable {
            var species: String
            var style: String
        }
    }
    
    public struct SummaryCoop : Codable {
//        var results: [ResultCoop]
//        var rewardGear
        public var summary: Summary
        
        public struct Summary: Codable {
            public var card: SummaryCard
            public var stats: [SummaryStat]
            
            public struct SummaryCard: Codable {
                public var goldenIkuraTotal: Int
                public var helpTotal: Int
                public var ikuraTotal: Int
                public var jobNum: Int
                public var kumaPoint: Int
                public var kumaPointTotal: Int
            }
            
            public struct SummaryStat: Codable {
                public var clearNum: Int
                public var deadTotal: Int
                public var endTime: Int
                public var failureCounts: [Int]
//              public   var grade
                public var gradePoint: Int
                public var helpTotal: Int
                public var jobNum: Int
                public var kumaPointTotal: Int
                public var myGoldenIkuraTotal: Int
                public var myIkuraTotal: Int
                public var startTime: Int
                public var teamGoldenIkuraTotal: Int
                public var teamIkuraTotal: Int
            }
        }
        
    }
    
    public struct NicknameIcons: Codable {
        public var nicknameAndIcons: [NicknameIcon]
        
        public struct NicknameIcon: Codable {
            public var nickname: String
            public var nsaId: String
            public var thumbnailUrl: String
        }
    }
}

protocol IdName: Codable {
    var id: String { get }
    var name: String { get }
}

protocol KeyName: Codable {
    var key: String { get }
    var name: String { get }
}

extension Response.ServerError {
    var localizedDescription: String? {
        // 有効な値が入っているものを返す
        if let errorDescription = errorDescription {
            return errorDescription
        }
        if let errorMessage = errorMessage {
            return errorMessage
        }
        if let error = error {
            return error
        }
        if let code = code {
            return code
        }
        return nil
    }
}
