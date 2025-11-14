////
////  MissionSelectionSheetView.swift
////  KIDK
////
////  Created by 잠만보김쥬디 on 11/14/25.
////
//
//import UIKit
//import SnapKit
//import RxSwift
//import RxCocoa
//
//final class MissionSelectionSheetView: UIView {
//    
//    private let disposeBag = DisposeBag()
//    
//    let missionSelected = PublishSubject<MissionType>()
//    let customMissionTapped = PublishSubject<Void>()
//    let previousMissionTapped = PublishSubject<Void>()
//    
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(hex: "#1C1C1E")
//        view.layer.cornerRadius = 20
//        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        return view
//    }()
//    
//    private let handleBar: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 2.5
//        return view
//    }()
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "어떤 미션을 해볼까요?"
//        label.font = .kidkTitle
//        label.textColor = .kidkTextWhite
//        return label
//    }()
//    
//    private let infoButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
//        button.tintColor = .kidkTextWhite
//        return button
//    }()
//    
//    private lazy var videoMissionCard: MissionCardButton = {
//        let card = MissionCardButton(
//            iconImage: UIImage(named: "kidk_mission_video"),
//            badge: "추천",
//            title: "영상 시청 후 퀴즈 풀기",
//            missionType: .video
//        )
//        return card
//    }()
//    
//    private lazy var studyMissionCard: MissionCardButton = {
//        let card = MissionCardButton(
//            iconImage: UIImage(named: "kidk_mission_study"),
//            badge: "추천",
//            title: "1시간씩 수학 공부를 하기",
//            missionType: .study
//        )
//        return card
//    }()
//    
//    private lazy var quizMissionCard: MissionCardButton = {
//        let card = MissionCardButton(
//            iconImage: UIImage(named: "kidk_mission_quiz"),
//            badge: "추천",
//            title: "30개씩 영어 단어를 외우기",
//            missionType: .quiz
//        )
//        return card
//    }()
//    
//    private let previousButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("이전으로", for: .normal)
//        button.titleLabel?.font = .kidkSubtitle
//        button.setTitleColor(.kidkTextWhite, for: .normal)
//        button.backgroundColor = UIColor(hex: "#2C2C2E")
//        button.layer.cornerRadius = CornerRadius.medium
//        return button
//    }()
//    
//    private let customMissionButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("직접 미션 설정하기", for: .normal)
//        button.titleLabel?.font = .kidkSubtitle
//        button.setTitleColor(.kidkTextWhite, for: .normal)
//        button.backgroundColor = .kidkPink
//        button.layer.cornerRadius = CornerRadius.medium
//        return button
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//        bind()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupUI() {
//        backgroundColor = .clear
//        
//        addSubview(containerView)
//        containerView.addSubview(handleBar)
//        containerView.addSubview(titleLabel)
//        containerView.addSubview(infoButton)
//        containerView.addSubview(videoMissionCard)
//        containerView.addSubview(studyMissionCard)
//        containerView.addSubview(quizMissionCard)
//        containerView.addSubview(previousButton)
//        containerView.addSubview(customMissionButton)
//        
//        containerView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.top.greaterThanOrEqualToSuperview().offset(100)
//        }
//        
//        handleBar.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(12)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(40)
//            make.height.equalTo(5)
//        }
//        
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(40)
//            make.leading.equalToSuperview().offset(Spacing.large)
//        }
//        
//        infoButton.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-Spacing.large)
//            make.centerY.equalTo(titleLabel)
//            make.width.height.equalTo(24)
//        }
//        
//        videoMissionCard.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.large)
//            make.leading.trailing.equalToSuperview().inset(Spacing.medium)
//            make.height.equalTo(70)
//        }
//        
//        studyMissionCard.snp.makeConstraints { make in
//            make.top.equalTo(videoMissionCard.snp.bottom).offset(Spacing.medium)
//            make.leading.trailing.equalToSuperview().inset(Spacing.medium)
//            make.height.equalTo(70)
//        }
//        
//        quizMissionCard.snp.makeConstraints { make in
//            make.top.equalTo(studyMissionCard.snp.bottom).offset(Spacing.medium)
//            make.leading.trailing.equalToSuperview().inset(Spacing.medium)
//            make.height.equalTo(70)
//        }
//        
//        previousButton.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(Spacing.medium)
//            make.top.equalTo(quizMissionCard.snp.bottom).offset(Spacing.large)
//            make.bottom.equalToSuperview().offset(-40)
//            make.height.equalTo(56)
//            make.width.equalTo(130)
//        }
//        
//        customMissionButton.snp.makeConstraints { make in
//            make.leading.equalTo(previousButton.snp.trailing).offset(Spacing.small)
//            make.trailing.equalToSuperview().offset(-Spacing.medium)
//            make.centerY.equalTo(previousButton)
//            make.height.equalTo(56)
//        }
//    }
//    
//    private func bind() {
//        videoMissionCard.rx.controlEvent(.touchUpInside)
//            .map { MissionType.video }
//            .bind(to: missionSelected)
//            .disposed(by: disposeBag)
//        
//        studyMissionCard.rx.controlEvent(.touchUpInside)
//            .map { MissionType.study }
//            .bind(to: missionSelected)
//            .disposed(by: disposeBag)
//        
//        quizMissionCard.rx.controlEvent(.touchUpInside)
//            .map { MissionType.quiz }
//            .bind(to: missionSelected)
//            .disposed(by: disposeBag)
//        
//        customMissionButton.rx.tap
//            .bind(to: customMissionTapped)
//            .disposed(by: disposeBag)
//        
//        previousButton.rx.tap
//            .bind(to: previousMissionTapped)
//            .disposed(by: disposeBag)
//    }
//}
//
//enum MissionType {
//    case video
//    case study
//    case quiz
//    case custom
//}
