import Foundation
import RxSwift
import RxCocoa

final class ParentChildInfoViewModel: BaseViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
    }

    struct Output {
        let childInfo: Driver<ChildInfo>
        let monthlyStats: Driver<MonthlyStats>
        let completedMissions: Driver<[Mission]>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }

    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let missionRepository: MissionRepositoryProtocol

    init(
        accountRepository: AccountRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol,
        missionRepository: MissionRepositoryProtocol
    ) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.missionRepository = missionRepository
        super.init()
    }

    func transform(input: Input) -> Output {
        let childInfoRelay = BehaviorRelay<ChildInfo>(value: createMockChildInfo())
        let monthlyStatsRelay = BehaviorRelay<MonthlyStats>(value: MonthlyStats())
        let completedMissionsRelay = BehaviorRelay<[Mission]>(value: [])

        input.viewDidLoad
            .do(onNext: { [weak self] _ in
                self?.startLoading()
            })
            .flatMapLatest { [weak self] _ -> Observable<([Account], [Mission])> in
                guard let self = self else {
                    return .empty()
                }

                let accountsObservable = self.accountRepository.getAllAccounts()
                    .asObservable()
                    .catchAndReturn([])

                // Mock userId 사용
                let missionsObservable = self.missionRepository.fetchMissionsByStatus(.completed, for: "child-001")
                    .asObservable()
                    .catchAndReturn([])

                return Observable.zip(accountsObservable, missionsObservable)
            }
            .subscribe(onNext: { [weak self] accounts, missions in
                guard let self = self else { return }

                // Calculate monthly stats
                let totalBalance = accounts.reduce(0) { $0 + $1.balance }
                let dailyLimit = 10000 // Mock 한도
                let totalSpending = 45000 // Mock 이번 달 지출
                let totalSavings = 25000 // Mock 이번 달 저축
                let usagePercentage = Double(totalSpending) / Double(dailyLimit * 30) // 월 한도 대비

                let monthlyStats = MonthlyStats(
                    totalSpending: totalSpending,
                    totalSavings: totalSavings,
                    dailyLimit: dailyLimit,
                    usagePercentage: usagePercentage
                )
                monthlyStatsRelay.accept(monthlyStats)

                // Update child info
                let updatedChildInfo = ChildInfo(
                    user: self.createMockChildInfo().user,
                    level: 5,
                    points: 250,
                    totalBalance: totalBalance
                )
                childInfoRelay.accept(updatedChildInfo)

                // Update completed missions
                completedMissionsRelay.accept(missions)

                self.stopLoading()
                self.debugSuccess("Data loaded successfully")
            }, onError: { [weak self] error in
                self?.handleError(error)
            })
            .disposed(by: disposeBag)

        return Output(
            childInfo: childInfoRelay.asDriver(),
            monthlyStats: monthlyStatsRelay.asDriver(),
            completedMissions: completedMissionsRelay.asDriver(),
            isLoading: isLoading.asDriver(),
            error: error.asDriver(onErrorJustReturn: NSError(domain: "", code: -1))
        )
    }

    // MARK: - Mock Data

    private func createMockChildInfo() -> ChildInfo {
        let mockUser = User(
            id: "child-001",
            firebaseUID: "firebase-child-001",
            userType: .child,
            name: "김시아",
            nickname: "시아",
            profileImageURL: nil,
            birthdate: nil
        )

        return ChildInfo(
            user: mockUser,
            level: 5,
            points: 250,
            totalBalance: 0
        )
    }
}
