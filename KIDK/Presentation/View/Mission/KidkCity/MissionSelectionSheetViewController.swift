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
        label.applyTextStyle(
            text: Strings.MissionSelection.title,
            size: .s26,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 120
        )
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "추천 미션",
            size: .s14,
            weight: .medium,
            color: .kidkGray,
            lineHeight: 120
        )
        return label
    }()

    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .kidkTextWhite.withAlphaComponent(0.75)
        return button
    }()

    private lazy var videoMissionCard: MissionCardButton = {
        let card = MissionCardButton(
            iconImage: assetImage(named: "kidk_mission_video"),
            badge: Strings.MissionSelection.recommendedBadge,
            title: Strings.MissionSelection.videoMission,
            missionType: .video
        )
        return card
    }()

    private lazy var studyMissionCard: MissionCardButton = {
        let card = MissionCardButton(
            iconImage: assetImage(named: "kidk_mission_study"),
            badge: Strings.MissionSelection.recommendedBadge,
            title: Strings.MissionSelection.studyMission,
            missionType: .study
        )
        return card
    }()

    private lazy var quizMissionCard: MissionCardButton = {
        let card = MissionCardButton(
            iconImage: assetImage(named: "kidk_mission_quiz"),
            badge: Strings.MissionSelection.recommendedBadge,
            title: Strings.MissionSelection.quizMission,
            missionType: .quiz
        )
        return card
    }()

    private let previousButton = KIDKButton(
        title: Strings.MissionSelection.previous,
        backgroundColor: UIColor(hex: "#2C2C2E"),
        titleColor: .kidkTextWhite
    )

    private let customMissionButton = KIDKButton(
        title: Strings.MissionSelection.customMission,
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
        view.addSubview(subtitleLabel)
        view.addSubview(infoButton)
        view.addSubview(videoMissionCard)
        view.addSubview(studyMissionCard)
        view.addSubview(quizMissionCard)
        view.addSubview(previousButton)
        view.addSubview(customMissionButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(Spacing.xl)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        infoButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.xl)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(24)
        }

        videoMissionCard.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(76)
        }

        studyMissionCard.snp.makeConstraints { make in
            make.top.equalTo(videoMissionCard.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(76)
        }

        quizMissionCard.snp.makeConstraints { make in
            make.top.equalTo(studyMissionCard.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(76)
        }

        previousButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.top.equalTo(quizMissionCard.snp.bottom).offset(Spacing.md)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.xs)
            make.height.equalTo(56)
            make.width.equalTo(132)
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

    private func assetImage(named name: String) -> UIImage? {
        return UIImage(named: name)
    }
}
