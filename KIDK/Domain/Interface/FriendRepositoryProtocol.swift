import Foundation
import RxSwift

protocol FriendRepositoryProtocol {
    func sendFriendRequest(_ request: FriendRequest) -> Single<Friend>
    func getFriends(for userId: String) -> Single<[Friend]>
    func deleteFriend(friendId: String) -> Completable
}
