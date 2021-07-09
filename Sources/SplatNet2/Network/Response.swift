import Foundation

public class Response: Codable {
    
    public struct ScheduleCoop: Codable {
        public var startTime: Int
        public var stageId: Int
        public var rareWeapon: Int
        public var endTime: Int
        public var weaponList: [Int]
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

    public struct ResultCoop: Codable {
        public var jobId: Int
        public var jobScore: Int
        public var jobRate: Int
        public var jobResult: JobResult
        public var schedule: Schedule
        public var kumaPoint: Int
        public var grade: Grade
        public var gradePoint: Int
        public var gradePointDelta: Int
        public var startTime: Int
        public var playTime: Int
        public var endTime: Int
        public var waveDetails: [WaveResult]
        public var dangerRate: Double
        public var bossCounts: [String: BossSalmonid]
        public var otherResults: [PlayerResult]
        public var myResult: PlayerResult

        public struct JobResult: Codable {
            public var failureReason: String?
            public var failureWave: Int?
            public var isClear: Bool
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(failureReason, forKey: .failureReason)
                try container.encode(failureWave, forKey: .failureWave)
                try container.encode(isClear, forKey: .isClear)
            }
        }

        public struct Schedule: Codable {
            public var stage: Stage
            public var startTime: Int
            public var endTime: Int
            public var weapons: [WeaponList]
        }

        public struct Grade: Codable {
            public var id: String
            public var longName: String
            public var name: String
            public var shortName: String
        }

        public struct Stage: Codable {
            public var image: String
            public var name: String
            public var stageId: Int {
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
            public var eventType: KeyName
            public var waterLevel: KeyName
            public var goldenIkuraNum: Int
            public var goldenIkuraPopNum: Int
            public var quotaNum: Int
            public var ikuraNum: Int
        }

        struct KeyName: Codable {
            public var key: String
            public var name: String
        }

        struct BossSalmonid: Codable {
            public var boss: KeyName
            public var count: Int
        }

        public struct PlayerResult: Codable {
            public var bossKillCounts: [String: BossSalmonid]
            public var deadCount: Int
            public var helpCount: Int
            public var ikuraNum: Int
            public var goldenIkuraNum: Int
            public var special: Special
            public var specialCounts: [Int]
            public var weaponList: [WeaponList]
            public var playerType: PlayerType
            public var name: String
            public var pid: String
        }

        struct Special: IdName, Codable {
            public var id: String
            public var name: String
        }

        struct WeaponList: Codable {
            public var id: String
            public var weapon: Weapon?
            public var coopSpecialWeapon: CoopWeapon?
        }

        struct Weapon: IdName, Codable {
            public var id: String
            public var name: String
            public var image: String
            public var thumbnail: String
        }
        
        struct CoopWeapon: Codable {
            public var image: String
            public var name: String
        }

        struct PlayerType: Codable {
            public var species: String
            public var style: String
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
