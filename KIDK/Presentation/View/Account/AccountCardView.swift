//TODO: XMARK 에셋으로 바꾸기
//
//  AccountCardView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class AccountCardView: UIView {
    
    let cardTapped = PublishRelay<Void>()
    let closeButtonTapped = PublishRelay<Void>()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .kidkGray
        button.isHidden = true
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(closeButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
        
        let tapGesture = UITapGestureRecognizer()
        containerView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .map { _ in () }
            .bind(to: cardTapped)
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        closeButton.rx.tap
            .bind(to: closeButtonTapped)
            .disposed(by: disposeBag)
    }
    
    func configure(with contentView: UIView, showCloseButton: Bool = false) {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStackView.addArrangedSubview(contentView)
        closeButton.isHidden = !showCloseButton
    }
}
