//
//  MissionVerificationRepositoryProtocol.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import Foundation
import RxSwift

protocol MissionVerificationRepositoryProtocol {
    /// 인증 제출
    func submitVerification(_ request: MissionVerificationRequest) -> Single<MissionVerification>

    /// 특정 미션의 인증 내역 조회
    func getVerifications(missionId: String) -> Single<[MissionVerification]>

    /// 대기 중인 인증 조회
    func getPendingVerifications() -> Single<[MissionVerification]>

    /// 인증 승인 (부모)
    func approveVerification(id: String) -> Single<MissionVerification>

    /// 인증 거절 (부모)
    func rejectVerification(id: String, reason: String) -> Single<MissionVerification>
}
