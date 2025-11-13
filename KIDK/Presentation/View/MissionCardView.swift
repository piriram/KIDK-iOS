//
//  MissionCardView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit
import SnapKit

final class MissionCardView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Mission.setGoalInKIDKCity
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Mission.setGoalWithFriends
        label.font = .kidkBody
        label.textColor = .kidkGray
        label.numberOfLines = 0
        return label
    }()

    private let whatMissionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Mission.whatMissionQuestion, for: .normal)
        button.titleLabel?.font = .kidkBody
        button.setTitleColor(.kidkPink, for: .normal)
        button.backgroundColor = UIColor(hex: "#1C1C1E")
        button.layer.cornerRadius = CornerRadius.small
        return button
    }()
    
    private let collapseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.tintColor = .kidkGray
        return button
    }()
    
    private let progressContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let progressCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        view.layer.cornerRadius = 100
        return view
    }()
    
    private let treasureIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .kidkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(collapseButton)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(progressContainerView)
        progressContainerView.addSubview(progressCircleView)
        progressCircleView.addSubview(treasureIconView)
        progressContainerView.addSubview(whatMissionButton)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.bottom.equalTo(whatMissionButton.snp.bottom).offset(Spacing.medium)
        }
        
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.medium)
            make.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        collapseButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Spacing.small)
            make.leading.trailing.equalToSuperview().inset(Spacing.medium)
        }
        
        progressContainerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.large)
            make.leading.trailing.equalToSuperview().inset(Spacing.medium)
        }
        
        progressCircleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        treasureIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        whatMissionButton.snp.makeConstraints { make in
            make.top.equalTo(progressCircleView.snp.bottom).offset(Spacing.large)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(200)
        }
    }
}
