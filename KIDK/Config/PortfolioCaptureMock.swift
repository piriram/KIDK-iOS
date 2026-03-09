import Foundation

enum PortfolioCaptureMock {
    #if DEBUG
    static let enabled = true
    #else
    static let enabled = false
    #endif

    static let childDisplayName = "파이리"

    static let primaryMissionTitle = "닌텐도 스위치 모으기"
    static let primaryMissionRewardAmount = 10_000
    static let primaryMissionTargetAmount = 300_000
    static let primaryMissionCurrentAmount = 240_000 // 80%

    static let spendingWalletAmount = 24_500
    static let savingsAccountAmount = 240_000

    static let loginEmail = "portfolio@kidk.com"
    static let loginPassword = "portfolio1234"
}
