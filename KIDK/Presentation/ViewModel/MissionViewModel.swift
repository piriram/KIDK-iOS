//
//  MissionViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MissionViewModel: BaseViewModel {
    
    struct Input {
        let goToKIDKCityTapped: Observable<Void>
        let missionInfoTapped: Observable<Void>
    }
    
    struct Output {
        let hasActiveMission: Driver<Bool>
        let isLoading: Driver<Bool>
    }
    
    let navigateToKIDKCity: PublishSubject<Void> = PublishSubject()
    
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init()
        debugLog("MissionViewModel initialized")
    }
    
    func transform(input: Input) -> Output {
        let hasActiveMission = BehaviorRelay<Bool>(value: false)
        
        input.goToKIDKCityTapped
            .subscribe(onNext: { [weak self] in
                self?.debugLog("Navigate to KIDK City")
                self?.navigateToKIDKCity.onNext(())
            })
            .disposed(by: disposeBag)
        
        return Output(
            hasActiveMission: hasActiveMission.asDriver(),
            isLoading: isLoading.asDriver()
        )
    }
}
