//
//  MissionViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MissionViewModel {
    
    struct Input {
        let goToKIDKCityTapped: Observable<Void>
        let missionInfoTapped: Observable<Void>
    }
    
    struct Output {
        let hasActiveMission: Driver<Bool>
    }
    
    let navigateToKIDKCity: PublishSubject<Void> = PublishSubject()
    
    private let user: User
    private let disposeBag = DisposeBag()
    
    init(user: User) {
        self.user = user
    }
    
    func transform(input: Input) -> Output {
        let hasActiveMission = BehaviorRelay<Bool>(value: false)
        
        input.goToKIDKCityTapped
            .subscribe(onNext: { [weak self] in
                self?.navigateToKIDKCity.onNext(())
            })
            .disposed(by: disposeBag)
        
        return Output(
            hasActiveMission: hasActiveMission.asDriver()
        )
    }
}
