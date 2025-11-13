//
//  KIDKCityViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift
import RxCocoa

final class KIDKCityViewModel {
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let locationTapped: Observable<KIDKCityLocationType>
    }
    
    struct Output {
        let shouldStartAutoWalk: Driver<Bool>
        let locations: Driver<[KIDKCityLocation]>
    }
    
    let navigateToLocation: PublishSubject<KIDKCityLocationType> = PublishSubject()
    
    private let user: User
    private let disposeBag = DisposeBag()
    
    init(user: User) {
        self.user = user
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
                self?.navigateToLocation.onNext(locationType)
            })
            .disposed(by: disposeBag)
        
        return Output(
            shouldStartAutoWalk: shouldStartAutoWalk.asDriver(),
            locations: locations.asDriver()
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
