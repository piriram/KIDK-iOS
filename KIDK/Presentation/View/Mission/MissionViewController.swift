//
//  MissionViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/13/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MissionViewController: BaseViewController {
    
    private let viewModel: MissionViewModel
    private let navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(text: Strings.Mission.title, size: .s24, weight: .bold, color: .kidkTextWhite)
        return label
    }()
    
    private let goToKIDKCityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Mission.goToKIDKCity, for: .normal)
        button.titleLabel?.font = .kidkTitle
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.medium
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Spacing.md, bottom: 0, right: Spacing.md)
        return button
    }()
    
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Mission.ongoingSavingMissions
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.tintColor = .kidkTextWhite
        return button
    }()
    
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .kidkTextWhite
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let sectionHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .kidkTextWhite.withAlphaComponent(0.6)
        return button
    }()
    
    private lazy var missionCardView: MissionCardView = {
        let view = MissionCardView()
        return view
    }()
    
    init(viewModel: MissionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground
        
        view.addSubview(navigationBar)
        navigationBar.addSubview(titleLabel)
        navigationBar.addSubview(menuButton)
        
        view.addSubview(goToKIDKCityButton)
        goToKIDKCityButton.addSubview(arrowImageView)
        
        view.addSubview(sectionHeaderView)
        sectionHeaderView.addSubview(sectionTitleLabel)
        sectionHeaderView.addSubview(infoButton)
        
        view.addSubview(missionCardView)
        
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.sm)
            make.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(24)
        }
        
        goToKIDKCityButton.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(64)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        sectionHeaderView.snp.makeConstraints { make in
            make.top.equalTo(goToKIDKCityButton.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(24)
        }
        
        sectionTitleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        infoButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        missionCardView.snp.makeConstraints { make in
            make.top.equalTo(sectionHeaderView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }
    }
    
    private func bind() {
        let input = MissionViewModel.Input(
            goToKIDKCityTapped: goToKIDKCityButton.rx.tap.asObservable(),
            missionInfoTapped: infoButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.hasActiveMission
            .drive()
            .disposed(by: disposeBag)
    }
}
