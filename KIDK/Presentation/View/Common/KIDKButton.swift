//
//  KIDKButton.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class KIDKButton: UIButton {
    
    private let disposeBag = DisposeBag()
    
    init(
        title: String,
        backgroundColor: UIColor = .kidkPink,
        titleColor: UIColor = .kidkTextWhite,
        font: UIFont = .systemFont(ofSize: 18)
    ) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = font
        self.backgroundColor = backgroundColor
        layer.cornerRadius = CornerRadius.small
        
        setupHighlightEffect()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHighlightEffect() {
        rx.controlEvent(.touchDown)
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.1) {
                    self?.alpha = 0.7
                    self?.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                }
            })
            .disposed(by: disposeBag)
        
        rx.controlEvent([.touchUpInside, .touchUpOutside, .touchCancel])
            .subscribe(onNext: { [weak self] in
                UIView.animate(withDuration: 0.1) {
                    self?.alpha = 1.0
                    self?.transform = .identity
                }
            })
            .disposed(by: disposeBag)
    }
    
    func updateTitle(_ title: String) {
        setTitle(title, for: .normal)
    }
}
