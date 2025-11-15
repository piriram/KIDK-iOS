//
//  MissionCardButton.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import UIKit
import SnapKit

final class MissionCardButton: UIControl {
    
    let missionType: MissionType
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()
    
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkTextSecondary
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .kidkPink
        return imageView
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkBody
        label.textColor = .kidkGray
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .kidkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(iconImage: UIImage?, badge: String, title: String, missionType: MissionType) {
        self.missionType = missionType
        super.init(frame: .zero)
        
        iconImageView.image = iconImage
        badgeLabel.text = badge
        titleLabel.text = title
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(badgeLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowImageView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconBackgroundView.snp.trailing).offset(Spacing.md)
            make.top.equalToSuperview().offset(Spacing.xs)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(badgeLabel)
            make.top.equalTo(badgeLabel.snp.bottom).offset(4)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-Spacing.xs)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.containerView.alpha = self.isHighlighted ? 0.7 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
}
