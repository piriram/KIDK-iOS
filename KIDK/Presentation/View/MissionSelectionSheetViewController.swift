//
//  MissionSelectionSheetViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MissionSelectionSheetViewController: BaseViewController {
    
    let missionSelected = PublishSubject<MissionType>()
    let customMissionTapped = PublishSubject<Void>()
    let previousMissionTapped = PublishSubject<Void>()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 미션을 해볼까요?"
        label.font = .kidkTitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .kidkTextWhite
        return button
    }()
    
    private lazy var videoMissionCard: MissionCardButton = {
        let card = MissionCardButton(
            iconImage: UIImage(named: "kidk_mission_video"),
            badge: "추천",
            title: "영상 시청 후 퀴즈 풀기",
            missionType: .video
        )
        return card
    }()
    
    private lazy var studyMissionCard: MissionCardButton = {
        let card = MissionCardButton(
            iconImage: UIImage(named: "kidk_mission_study"),
            badge: "추천",
            title: "1시간씩 수학 공부를 하기",
            missionType: .study
        )
        return card
    }()
    
    private lazy var quizMissionCard: MissionCardButton = {
        let card = MissionCardButton(
            iconImage: UIImage(named: "kidk_mission_quiz"),
            badge: "추천",
            title: "30개씩 영어 단어를 외우기",
            missionType: .quiz
        )
        return card
    }()
    
    private let previousButton = KIDKButton(
        title: "이전으로",
        backgroundColor: UIColor(hex: "#2C2C2E"),
        titleColor: .kidkTextWhite
    )
    
    private let customMissionButton = KIDKButton(
        title: "직접 미션 설정하기",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        
        view.addSubview(titleLabel)
        view.addSubview(infoButton)
        view.addSubview(videoMissionCard)
        view.addSubview(studyMissionCard)
        view.addSubview(quizMissionCard)
        view.addSubview(previousButton)
        view.addSubview(customMissionButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalToSuperview().offset(Spacing.xl)
        }
        
        infoButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.xl)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(24)
        }
        
        videoMissionCard.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(70)
        }
        
        studyMissionCard.snp.makeConstraints { make in
            make.top.equalTo(videoMissionCard.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(70)
        }
        
        quizMissionCard.snp.makeConstraints { make in
            make.top.equalTo(studyMissionCard.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(70)
        }
        
        previousButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalTo(quizMissionCard.snp.bottom).offset(Spacing.xl)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.md)
            make.height.equalTo(56)
            make.width.equalTo(130)
        }
        
        customMissionButton.snp.makeConstraints { make in
            make.leading.equalTo(previousButton.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalTo(previousButton)
            make.height.equalTo(56)
        }
    }
    
    private func bind() {
        videoMissionCard.rx.controlEvent(.touchUpInside)
            .map { MissionType.video }
            .bind(to: missionSelected)
            .disposed(by: disposeBag)
        
        studyMissionCard.rx.controlEvent(.touchUpInside)
            .map { MissionType.study }
            .bind(to: missionSelected)
            .disposed(by: disposeBag)
        
        quizMissionCard.rx.controlEvent(.touchUpInside)
            .map { MissionType.quiz }
            .bind(to: missionSelected)
            .disposed(by: disposeBag)
        
        customMissionButton.rx.tap
            .bind(to: customMissionTapped)
            .disposed(by: disposeBag)
        
        previousButton.rx.tap
            .bind(to: previousMissionTapped)
            .disposed(by: disposeBag)
    }
}

enum MissionType {
    case video
    case study
    case quiz
    case custom
}
