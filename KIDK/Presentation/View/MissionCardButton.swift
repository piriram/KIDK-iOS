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
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        return label
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkBody
        label.textColor = .kidkTextWhite
        label.text = "추천"
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        label.numberOfLines = 2
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .kidkTextWhite
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(icon: String, badge: String, title: String, missionType: MissionType) {
        self.missionType = missionType
        super.init(frame: .zero)
        
        iconLabel.text = icon
        badgeLabel.text = badge
        titleLabel.text = title
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(badgeLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowImageView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.medium)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(Spacing.small)
            make.top.equalToSuperview().offset(Spacing.medium)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(badgeLabel)
            make.top.equalTo(badgeLabel.snp.bottom).offset(4)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-Spacing.small)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.medium)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.containerView.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}
