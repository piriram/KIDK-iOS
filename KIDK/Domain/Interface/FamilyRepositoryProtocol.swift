//
//  FamilyRepositoryProtocol.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import Foundation
import RxSwift

protocol FamilyRepositoryProtocol {
    // Family
    func createFamily(_ request: FamilyCreationRequest) -> Single<Family>
    func getFamilies(for userId: String) -> Single<[Family]>
    func joinFamily(_ request: FamilyJoinRequest) -> Single<Family>

    // Family Member
    func getFamilyMembers(familyId: String) -> Single<[FamilyMember]>
    func removeFamilyMember(familyMemberId: String) -> Completable
}
