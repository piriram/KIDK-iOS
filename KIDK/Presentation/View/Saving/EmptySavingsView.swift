//
//  EmptySavingsView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EmptySavingsView: UIView {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .kidkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "저축 목표가 없어요"
        label.font = .kidkFont(.s20, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "첫 저축 목표를 만들어보세요\n목표를 달성하고 보상을 받을 수 있어요!"
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkTextWhite.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저축 목표 만들기", for: .normal)
        button.titleLabel?.font = .kidkFont(.s16, .bold)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.medium
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(createButton)

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.width.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        createButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Spacing.xl)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
        }
    }

    var createButtonTapped: Observable<Void> {
        createButton.rx.tap.asObservable()
    }
}
