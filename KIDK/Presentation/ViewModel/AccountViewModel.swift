//
//  AccountViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import Foundation
import RxSwift
import RxCocoa

final class AccountViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        let isLoading: Driver<Bool>
    }
    
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init()
        debugLog("AccountViewModel initialized with user: \(user.name)")
    }
    
    func transform(input: Input) -> Output {
        return Output(
            isLoading: isLoading.asDriver()
        )
    }
}
