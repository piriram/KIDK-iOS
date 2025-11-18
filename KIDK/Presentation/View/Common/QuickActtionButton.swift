//
//  QuickActtionButton.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

final class QuickActionButton: UIButton {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    let actionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 14, weight: .medium)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        return label
    }()

    init(action: QuickActionType) {
        super.init(frame: .zero)
        configure(with: action)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#2C2C2E")
        layer.cornerRadius = 12

        addSubview(iconImageView)
        addSubview(actionTitleLabel)

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(32)
        }

        actionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    private func configure(with action: QuickActionType) {
        iconImageView.image = UIImage(systemName: action.iconName)
        iconImageView.tintColor = action.iconColor
        actionTitleLabel.text = action.title
    }
}
