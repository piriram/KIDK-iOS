//
//  FriendRepositoryProtocol.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation
import RxSwift

protocol FriendRepositoryProtocol {
    func sendFriendRequest(_ request: FriendRequest) -> Single<Friend>
    func getFriends(for userId: String) -> Single<[Friend]>
    func deleteFriend(friendId: String) -> Completable
}
