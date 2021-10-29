# SplatNet2

SplatNet2 is the framework to generate iksm_session using internal and external API to get JSON from SplatNet2.

## Installation

### Requirements
* iOS13.0+
* Xcode 11+

### CocoaPods

```ruby
pod 'SplatNet2'
```

### SPM(Swift Package Manager)

```swift
dependencies: [
    .package(url: "https://github.com/tkgstrator/SplatNet2.git")
]
```

## Usage

### session_token_code
Generating iksm_session, we must need `session_token_code` and `session_token_code_verifier` given by random byte strings. Moreover, `session_token_code` is provided by `oauth_url` like [this](https://accounts.nintendo.com/connect/1.0.0/authorize?state=DthLWOg54YPRnkPpxhY0aMyxEfSdmRplaOtIlIJimBxnAhbM&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=8PlJorbqc1oUmynjgtICD3JzrNd3oez9kTeEYBCsXls&session_token_code_challenge_method=S256&theme=login_form).

[This](https://salmonia.mydns.jp) website could help you to get them. They(`auth_url` and `auth_code_verifier`) are reusable, you don't have to access twice.

### get iksm_session

```swift
import SplatNet2
import Combine

var task = Set<AnyCancellable>()

manager.getResultCoop(jobId: 1)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            promise(.failure(error))
        }
    }, receiveValue: { response in
       // Response
    })
    .store(in: &task)
```

### nickname and icons

Nintendo provides the API to get nickname and icons by nsaid(this is named as *nsa-data-id/pid/principal id*).

```swift
import SplatNet2
import Combine

var task = Set<AnyCancellable>()

manager.getNicknameAndIcons(jobId: 1)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            break
        case .failure(let error):
            promise(.failure(error))
        }
    }, receiveValue: { response in
       // Response
    })
    .store(in: &task)
```

