import Foundation
import RxSwift
import RxCocoa

final class AccountViewModel: BaseViewModel {

    struct Input {
        let viewDidLoad: Observable<Void>
        let viewWillAppear: Observable<Void>
    }

    struct Output {
        let isLoading: Driver<Bool>
        let accounts: Driver<[Account]>
        let primaryAccount: Driver<Account?>
    }

    /*private*/ let user: User
    private let accountRepository: AccountRepositoryProtocol

    init(user: User, accountRepository: AccountRepositoryProtocol = AccountRepository.shared) {
        self.user = user
        self.accountRepository = accountRepository
        super.init()
        debugLog("AccountViewModel initialized with user: \(user.name)")
    }

    func transform(input: Input) -> Output {
        let accounts = BehaviorRelay<[Account]>(value: [])
        let primaryAccount = BehaviorRelay<Account?>(value: nil)

        // viewDidLoad와 viewWillAppear에서 계좌 정보 로드
        Observable.merge(input.viewDidLoad, input.viewWillAppear)
            .do(onNext: { [weak self] in
                self?.startLoading()
            })
            .flatMapLatest { [weak self] _ -> Single<[Account]> in
                guard let self = self else { return .just([]) }
                return self.accountRepository.getAllAccounts()
            }
            .subscribe(onNext: { [weak self] fetchedAccounts in
                self?.stopLoading()
                accounts.accept(fetchedAccounts)

                // primary account 찾기
                if let primary = fetchedAccounts.first(where: { $0.isPrimary }) {
                    primaryAccount.accept(primary)
                }

                self?.debugSuccess("Loaded \(fetchedAccounts.count) accounts")
            }, onError: { [weak self] error in
                self?.stopLoading()
                self?.handleError(error)
            })
            .disposed(by: disposeBag)

        return Output(
            isLoading: isLoading.asDriver(),
            accounts: accounts.asDriver(),
            primaryAccount: primaryAccount.asDriver()
        )
    }
}
