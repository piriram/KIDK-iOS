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
        label.applyTextStyle(
            text: "",
            size: .s20,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s14,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(title: String, subtitle: String? = nil) {
        titleLabel.text = title
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
}

