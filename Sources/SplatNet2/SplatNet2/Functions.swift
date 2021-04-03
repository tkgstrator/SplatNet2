//
//  File.swift
//  
//
//  Created by devonly on 2021/04/04.
//

import Foundation
import Combine

extension SplatNet2 {

    // Error Response
    // [400] Invalid GrantType
    @discardableResult
    public func getCookie(sessionToken: String, version: String = "1.10.1") -> Future<APIResponse.UserInfo, APIError> {
        let request = APIRequest.AccessToken(sessionToken: sessionToken)
        var task: [AnyCancellable?] = []

        return Future { [self] promise in
            task.append(
                NetworkPublisher.publish(request)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { _ in
                    }, receiveValue: { (response: APIResponse.AccessToken) in
                        task.append(
                            getSplatoonToken(accessToken: response.accessToken)
                                .receive(on: DispatchQueue.main)
                                .sink(receiveCompletion: { _ in
                                }, receiveValue: { response in
                                    let accessToken = response.result.webApiServerCredential.accessToken
                                    let name = response.result.user.name
                                    let imageUri = response.result.user.imageUri
                                    let membership = response.result.user.membership.active
                                    let expiresIn = response.result.webApiServerCredential.expiresIn
                                    task.append(
                                        getSplatoonAccessToken(splatoonToken: accessToken, version: version)
                                            .receive(on: DispatchQueue.main)
                                            .sink(receiveCompletion: { _ in
                                            }, receiveValue: { response in
                                                let accessToken = response.result.accessToken
                                                task.append(
                                                    getIksmSession(accessToken: accessToken)
                                                        .receive(on: DispatchQueue.main)
                                                        .sink(receiveCompletion: { _ in
                                                        }, receiveValue: { response in
                                                            let iksmSession = response.iksmSession
                                                            let nsaid = response.nsaid
                                                            let userInfo = APIResponse.UserInfo(iksmSession: iksmSession, nsaid: nsaid, membership: membership, imageUri: imageUri, expiresIn: expiresIn)
                                                            promise(.success(userInfo))
                                                        }))
                                            }))
                                }))
                    }))
        }
    }
}
