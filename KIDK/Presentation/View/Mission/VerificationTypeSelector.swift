//
//  VerificationTypeSelector.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class VerificationTypeSelector: UIView {

    private let disposeBag = DisposeBag()
    private let selectedTypeRelay = BehaviorRelay<VerificationType>(value: .photo)

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.sm
        stackView.distribution = .fillEqually
        return stackView
    }()

    var selectedType: Observable<VerificationType> {
        return selectedTypeRelay.asObservable()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Add photo and text options (skip parentCheck for Phase 1)
        let types: [VerificationType] = [.photo, .text]

        for type in types {
            let button = createTypeButton(for: type)
            stackView.addArrangedSubview(button)
        }
    }

    private func createTypeButton(for type: VerificationType) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = CornerRadius.medium
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: Spacing.md, left: Spacing.md, bottom: Spacing.md, right: Spacing.md)

        let iconLabel = UILabel()
        iconLabel.text = type.icon
        iconLabel.font = .systemFont(ofSize: 24)

        let titleLabel = UILabel()
        titleLabel.text = type.displayName
        titleLabel.font = .kidkFont(.s16, .medium)
        titleLabel.textColor = .kidkTextWhite

        let radioView = UIView()
        radioView.backgroundColor = .clear
        radioView.layer.cornerRadius = 10
        radioView.layer.borderWidth = 2
        radioView.layer.borderColor = UIColor.kidkGray.cgColor
        radioView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }

        let containerView = UIView()
        containerView.isUserInteractionEnabled = false

        button.addSubview(containerView)
        containerView.addSubview(radioView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(32)
        }

        radioView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        iconLabel.snp.makeConstraints { make in
            make.leading.equalTo(radioView.snp.trailing).offset(Spacing.sm)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(Spacing.xs)
            make.centerY.equalToSuperview()
        }

        // Store radioView as tag for later access
        radioView.tag = 999

        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectType(type, button: button)
            })
            .disposed(by: disposeBag)

        // Set initial selection
        if type == selectedTypeRelay.value {
            radioView.backgroundColor = .kidkPink
            radioView.layer.borderColor = UIColor.kidkPink.cgColor
            button.backgroundColor = UIColor.kidkPink.withAlphaComponent(0.2)
        }

        return button
    }

    private func selectType(_ type: VerificationType, button selectedButton: UIButton) {
        selectedTypeRelay.accept(type)

        // Update all buttons
        stackView.arrangedSubviews.forEach { view in
            guard let btn = view as? UIButton else { return }
            let radioView = btn.viewWithTag(999)

            if btn == selectedButton {
                // Selected
                radioView?.backgroundColor = .kidkPink
                radioView?.layer.borderColor = UIColor.kidkPink.cgColor
                btn.backgroundColor = UIColor.kidkPink.withAlphaComponent(0.2)

                // Scale animation
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                    btn.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        btn.transform = .identity
                    }
                }
            } else {
                // Deselected
                radioView?.backgroundColor = .clear
                radioView?.layer.borderColor = UIColor.kidkGray.cgColor
                btn.backgroundColor = UIColor(hex: "#2C2C2E")
            }
        }
    }
}
