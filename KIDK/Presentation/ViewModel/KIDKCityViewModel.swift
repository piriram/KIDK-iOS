import Foundation
import RxSwift
import RxCocoa

final class KIDKCityViewModel: BaseViewModel {
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let locationTapped: Observable<KIDKCityLocationType>
    }
    
    struct Output {
        let shouldStartAutoWalk: Driver<Bool>
        let locations: Driver<[KIDKCityLocation]>
        let isLoading: Driver<Bool>
    }
    
    let navigateToLocation: PublishSubject<KIDKCityLocationType> = PublishSubject()
    
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init()
        debugLog("KIDKCityViewModel initialized")
    }
    
    func transform(input: Input) -> Output {
        let shouldStartAutoWalk = BehaviorRelay<Bool>(value: true)
        let locations = BehaviorRelay<[KIDKCityLocation]>(value: createLocations())
        
        input.viewDidAppear
            .take(1)
            .map { true }
            .bind(to: shouldStartAutoWalk)
            .disposed(by: disposeBag)
        
        input.locationTapped
            .subscribe(onNext: { [weak self] locationType in
                self?.debugLog("Location tapped: \(locationType)")
                self?.navigateToLocation.onNext(locationType)
            })
            .disposed(by: disposeBag)
        
        return Output(
            shouldStartAutoWalk: shouldStartAutoWalk.asDriver(),
            locations: locations.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }
    
    private func createLocations() -> [KIDKCityLocation] {
        return [
            KIDKCityLocation(
                type: .school,
                position: CGPoint(x: 0.5, y: 0.3),
                isUnlocked: true,
                requiredLevel: 20
            ),
            KIDKCityLocation(
                type: .mart,
                position: CGPoint(x: 0.7, y: 0.7),
                isUnlocked: false,
                requiredLevel: 10
            )
        ]
    }
}
