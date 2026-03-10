import Foundation
import RxSwift
import RxCocoa

final class WalletViewModel: BaseViewModel {

    // MARK: - Dependencies
    private let accountRepository: AccountRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let savingsRepository: SavingsRepositoryProtocol

    // MARK: - Outputs
    let accounts: BehaviorRelay<[Account]>
    let transactions: BehaviorRelay<[Transaction]>
    let savingsGoals: BehaviorRelay<[SavingsGoal]>
    let card: BehaviorRelay<Card?>
    let userLevel: BehaviorRelay<Int>
    let userExperience: BehaviorRelay<Int>
    let dailySpendingLimit: BehaviorRelay<Int>

    // MARK: - Initialization
    init(
        accountRepository: AccountRepositoryProtocol = AccountRepository.shared,
        transactionRepository: TransactionRepositoryProtocol = TransactionRepository.shared,
        savingsRepository: SavingsRepositoryProtocol = SavingsRepository.shared
    ) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.savingsRepository = savingsRepository

        // Initialize relays with empty data
        self.accounts = BehaviorRelay(value: [])
        self.transactions = BehaviorRelay(value: [])
        self.savingsGoals = BehaviorRelay(value: [])

        // Mock data for features not yet connected to repositories
        let mockCard = Card(
            id: "1",
            characterImageName: "kidk_profile_one",
            isPhysicalCard: true,
            status: .active,
            lastFourDigits: "1234"
        )
        self.card = BehaviorRelay(value: mockCard)
        self.userLevel = BehaviorRelay(value: 8)
        self.userExperience = BehaviorRelay(value: 800)
        self.dailySpendingLimit = BehaviorRelay(value: 12_000)

        super.init()

        // Load initial data
        loadData()

        // Subscribe to transaction creation notifications
        NotificationCenter.default.rx
            .notification(.transactionCreated)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.debugSuccess("Transaction notification received - refreshing data")
                self?.loadData()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Methods
    func refreshData() {
        loadData()
    }

    func getPrimaryAccount() -> Account? {
        return accounts.value.first { $0.isPrimary }
    }

    func getTotalBalance() -> Int {
        return accounts.value.reduce(0) { $0 + $1.balance }
    }

    func getTransactionsByDate() -> [String: [Transaction]] {
        let calendar = Calendar.current
        var groupedTransactions: [String: [Transaction]] = [:]

        for transaction in transactions.value {
            let dateString = transaction.formattedDateWithDay
            if groupedTransactions[dateString] == nil {
                groupedTransactions[dateString] = []
            }
            groupedTransactions[dateString]?.append(transaction)
        }

        return groupedTransactions
    }

    func filterTransactions(by type: TransactionType?) -> [Transaction] {
        guard let type = type else {
            return transactions.value
        }
        return transactions.value.filter { $0.type == type }
    }

    func filterTransactions(by category: TransactionCategory?) -> [Transaction] {
        guard let category = category else {
            return transactions.value
        }
        return transactions.value.filter { $0.category == category }
    }

    // MARK: - Private Methods
    private func loadData() {
        isLoading.accept(true)

        if PortfolioCaptureMock.enabled {
            accounts.accept(createPortfolioMockAccounts())
            transactions.accept(createPortfolioMockTransactions())
            savingsGoals.accept(createPortfolioMockSavingsGoals())
            isLoading.accept(false)
            return
        }

        // Fetch all data in parallel
        Observable.zip(
            fetchAccounts(),
            fetchTransactions(),
            fetchSavingsGoals()
        )
        .observe(on: MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] accounts, transactions, savingsGoals in
                self?.accounts.accept(accounts)
                self?.transactions.accept(transactions)
                self?.savingsGoals.accept(savingsGoals)
                self?.isLoading.accept(false)
                self?.debugSuccess("Data loaded successfully")
            },
            onError: { [weak self] error in
                self?.isLoading.accept(false)
                self?.error.onNext(error)
                self?.debugError("Failed to load data", error: error)
            }
        )
        .disposed(by: disposeBag)
    }

    private func fetchAccounts() -> Observable<[Account]> {
        return accountRepository.getAllAccounts()
            .asObservable()
            .catch { [weak self] error in
                self?.debugError("Failed to fetch accounts", error: error)
                return .just([])
            }
    }

    private func fetchTransactions() -> Observable<[Transaction]> {
        // Get primary account to fetch its transactions
        return accountRepository.getPrimaryAccount()
            .asObservable()
            .flatMap { [weak self] primaryAccount -> Observable<[Transaction]> in
                guard let self = self, let account = primaryAccount else {
                    return .just([])
                }
                return self.transactionRepository.fetchTransactions(for: account.id)
                    .asObservable()
            }
            .catch { [weak self] error in
                self?.debugError("Failed to fetch transactions", error: error)
                return .just(self?.createMockTransactions() ?? [])
            }
    }

    private func fetchSavingsGoals() -> Observable<[SavingsGoal]> {
        return savingsRepository.fetchSavingsGoals()
            .asObservable()
            .catch { [weak self] error in
                self?.debugError("Failed to fetch savings goals", error: error)
                return .just([])
            }
    }

    private func createPortfolioMockAccounts() -> [Account] {
        [
            Account(
                id: "portfolio-spending",
                type: .spending,
                name: "내 지갑",
                balance: PortfolioCaptureMock.spendingWalletAmount,
                isPrimary: true
            ),
            Account(
                id: "portfolio-savings",
                type: .savings,
                name: "내 용돈통장",
                balance: PortfolioCaptureMock.savingsAccountAmount,
                isPrimary: false
            )
        ]
    }

    private func createPortfolioMockSavingsGoals() -> [SavingsGoal] {
        [
            SavingsGoal(
                id: "portfolio-goal-1",
                userId: "portfolio-user",
                name: PortfolioCaptureMock.primaryMissionTitle,
                targetAmount: PortfolioCaptureMock.primaryMissionTargetAmount,
                currentAmount: PortfolioCaptureMock.primaryMissionCurrentAmount,
                imageName: "game",
                imageData: nil,
                startDate: Date().addingTimeInterval(-25 * 24 * 60 * 60),
                targetDate: Date().addingTimeInterval(35 * 24 * 60 * 60),
                status: .inProgress,
                createdAt: Date().addingTimeInterval(-25 * 24 * 60 * 60),
                completedAt: nil,
                linkedMissionIds: ["mission1"]
            )
        ]
    }

    private func createPortfolioMockTransactions() -> [Transaction] {
        [
            Transaction(
                id: "portfolio-1",
                type: .missionReward,
                category: nil,
                amount: PortfolioCaptureMock.primaryMissionRewardAmount,
                description: "\(PortfolioCaptureMock.primaryMissionTitle) 미션 완료",
                memo: nil,
                balanceAfter: PortfolioCaptureMock.spendingWalletAmount,
                date: Date().addingTimeInterval(-3600)
            ),
            Transaction(
                id: "portfolio-2",
                type: .transfer,
                category: nil,
                amount: 20_000,
                description: "내 용돈통장으로 이체",
                memo: "목표 저축",
                balanceAfter: 14_500,
                date: Date().addingTimeInterval(-7200)
            ),
            Transaction(
                id: "portfolio-3",
                type: .withdrawal,
                category: .shopping,
                amount: 4_500,
                description: "키드키드 편의점",
                memo: "영수증 OCR 저장",
                balanceAfter: 34_500,
                date: Date().addingTimeInterval(-86400)
            )
        ]
    }

    // Fallback mock transactions for when repository returns empty
    private func createMockTransactions() -> [Transaction] {
        return [
            Transaction(
                id: "1",
                type: .missionReward,
                category: nil,
                amount: PortfolioCaptureMock.primaryMissionRewardAmount,
                description: "\(PortfolioCaptureMock.primaryMissionTitle) 미션 완료",
                memo: nil,
                balanceAfter: PortfolioCaptureMock.spendingWalletAmount,
                date: Date().addingTimeInterval(-3600)
            ),
            Transaction(
                id: "2",
                type: .withdrawal,
                category: .food,
                amount: 3500,
                description: "편의점 간식",
                memo: "초코바, 우유",
                balanceAfter: 11450,
                date: Date().addingTimeInterval(-7200)
            ),
            Transaction(
                id: "3",
                type: .deposit,
                category: nil,
                amount: 5000,
                description: "용돈",
                memo: "엄마가 주신 용돈",
                balanceAfter: 14950,
                date: Date().addingTimeInterval(-86400)
            ),
            Transaction(
                id: "4",
                type: .withdrawal,
                category: .school,
                amount: 15000,
                description: "문구점",
                memo: "노트, 필통",
                balanceAfter: 9950,
                date: Date().addingTimeInterval(-172800)
            ),
            Transaction(
                id: "5",
                type: .transfer,
                category: nil,
                amount: 10000,
                description: "저축 통장으로 이체",
                memo: nil,
                balanceAfter: 24950,
                date: Date().addingTimeInterval(-259200)
            )
        ]
    }
}
