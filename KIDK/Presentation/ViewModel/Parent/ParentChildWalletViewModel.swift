import Foundation
import RxSwift
import RxCocoa

final class ParentChildWalletViewModel: BaseViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshTriggered: Observable<Void>
    }

    struct Output {
        let childInfo: Driver<ChildInfo>
        let accounts: Driver<[Account]>
        let recentTransactions: Driver<[Transaction]>
        let isLoading: Driver<Bool>
        let error: Driver<Error>
    }

    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol

    init(
        accountRepository: AccountRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol
    ) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        super.init()
    }

    func transform(input: Input) -> Output {
        let childInfoRelay = BehaviorRelay<ChildInfo>(value: createMockChildInfo())
        let accountsRelay = BehaviorRelay<[Account]>(value: [])
        let transactionsRelay = BehaviorRelay<[Transaction]>(value: [])

        let loadTrigger = Observable.merge(
            input.viewDidLoad,
            input.refreshTriggered
        )

        loadTrigger
            .do(onNext: { [weak self] _ in
                self?.startLoading()
            })
            .flatMapLatest { [weak self] _ -> Observable<([Account], [Transaction])> in
                guard let self = self else {
                    return .empty()
                }

                let accountsObservable = self.accountRepository.getAllAccounts()
                    .asObservable()
                    .catchAndReturn([])

                let transactionsObservable = self.accountRepository.getAllAccounts()
                    .asObservable()
                    .flatMap { accounts -> Single<[Transaction]> in
                        guard let firstAccount = accounts.first else {
                            return .just([])
                        }
                        return self.transactionRepository.fetchTransactions(for: firstAccount.id)
                    }
                    .catchAndReturn([])

                return Observable.zip(accountsObservable, transactionsObservable)
            }
            .subscribe(onNext: { [weak self] accounts, transactions in
                guard let self = self else { return }

                accountsRelay.accept(accounts)

                // 최근 5개만 필터링 (날짜 내림차순)
                let recentTransactions = Array(transactions.prefix(5))
                transactionsRelay.accept(recentTransactions)

                // ChildInfo 업데이트 (총 잔액 계산)
                let totalBalance = accounts.reduce(0) { $0 + $1.balance }
                let updatedChildInfo = ChildInfo(
                    user: self.createMockChildInfo().user,
                    level: 5,
                    points: 250,
                    totalBalance: totalBalance
                )
                childInfoRelay.accept(updatedChildInfo)

                self.stopLoading()
                self.debugSuccess("Data loaded successfully")
            }, onError: { [weak self] error in
                self?.handleError(error)
            })
            .disposed(by: disposeBag)

        return Output(
            childInfo: childInfoRelay.asDriver(),
            accounts: accountsRelay.asDriver(),
            recentTransactions: transactionsRelay.asDriver(),
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
