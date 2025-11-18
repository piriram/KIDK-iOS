//
//  SectionHeaderView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

final class SectionHeaderView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 20, weight: .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .spoqaHanSansNeo(size: 14, weight: .medium)
        button.setTitleColor(.kidkGray, for: .normal)
        return button
    }()

    var actionHandler: (() -> Void)?

    init(title: String, actionTitle: String? = nil) {
        super.init(frame: .zero)
        titleLabel.text = title
        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(actionButton)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    @objc private func actionButtonTapped() {
        actionHandler?()
    }
}
