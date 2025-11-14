//
//  AccountViewModel.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import Foundation
import RxSwift
import RxCocoa

final class AccountViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private let user: User
    private let disposeBag = DisposeBag()
    
    init(user: User) {
        self.user = user
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
