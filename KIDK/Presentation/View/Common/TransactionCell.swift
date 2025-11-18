//
//  TransactionCell.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

final class TransactionCell: UITableViewCell {

    static let identifier = "TransactionCell"

    private let categoryIconView: IconContainerView = {
        let view = IconContainerView("kidk_icon_wallet", size: 40, iconSize: 28)
        return view
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 16, weight: .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 14, weight: .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 18, weight: .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .right
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .spoqaHanSansNeo(size: 12, weight: .medium)
        label.textColor = .kidkGray
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#2C2C2E")
        selectionStyle = .none

        contentView.addSubview(categoryIconView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(timeLabel)

        categoryIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryIconView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
        }

        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(descriptionLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }

        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.leading.greaterThanOrEqualTo(descriptionLabel.snp.trailing).offset(8)
        }

        timeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(amountLabel)
            make.top.equalTo(amountLabel.snp.bottom).offset(4)
        }
    }

    func configure(with transaction: Transaction) {
        descriptionLabel.text = transaction.description
        categoryLabel.text = transaction.category?.rawValue ?? transaction.type.displayName
        amountLabel.text = transaction.formattedAmount
        timeLabel.text = transaction.formattedDate

        // 금액 색상 설정
        if transaction.type == .deposit || transaction.type == .missionReward {
            amountLabel.textColor = .kidkGreen
        } else {
            amountLabel.textColor = .kidkPink
        }

        // 카테고리 아이콘 설정
        if let category = transaction.category {
            categoryIconView.updateIcon(category.iconName)
            categoryIconView.backgroundColor = category.color.withAlphaComponent(0.2)
        } else {
            categoryIconView.updateIcon("kidk_icon_wallet")
            categoryIconView.backgroundColor = .kidkGray.withAlphaComponent(0.2)
        }
    }
}

// IconContainerView에 updateIcon 메서드 추가를 위한 extension
extension IconContainerView {
    func updateIcon(_ iconName: String) {
        // 기존 아이콘 제거
        subviews.forEach { $0.removeFromSuperview() }

        // 새 아이콘 추가
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: iconName)
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.7)
        }
    }
}
