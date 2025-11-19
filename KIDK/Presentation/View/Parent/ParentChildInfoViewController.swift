//
//  ParentChildInfoViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

/// Phase 1: 목업 데이터로 아이 정보 표시
/// Phase 2: 실제 Repository 연동
final class ParentChildInfoViewController: BaseViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    // MARK: - Profile Section

    private let profileCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let profileImageView = ProfileImageView(
        assetName: "kidk_profile_one",
        size: 80,
        bgColor: .white,
        iconRatio: 0.7
    )

    private let childNameLabel: UILabel = {
        let label = UILabel()
        label.text = "김시아"
        label.font = .kidkFont(.s24, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let childAgeLabel: UILabel = {
        let label = UILabel()
        label.text = "9세 · 초등학교 3학년"
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        return label
    }()

    // MARK: - Level & Experience Section

    private let levelCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let levelLabel: UILabel = {
        let label = UILabel()
        label.text = "레벨 5"
        label.font = .kidkFont(.s20, .bold)
        label.textColor = .kidkPink
        return label
    }()

    private let expLabel: UILabel = {
        let label = UILabel()
        label.text = "경험치 750 / 1000"
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let expProgressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = UIColor(hex: "#3C3C3E")
        progress.progressTintColor = .kidkPink
        progress.progress = 0.75
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        return progress
    }()

    // MARK: - Statistics Section

    private let statsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "미션 통계"
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Spacing.sm
        return stackView
    }()

    // MARK: - Ongoing Missions Section

    private let ongoingMissionsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "진행 중인 미션"
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let ongoingMissionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.sm
        return stackView
    }()

    // MARK: - Recent Activity Section

    private let recentActivitySectionLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 활동"
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let recentActivityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xs
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        loadMockData()
    }

    private func setupNavigationBar() {
        title = "아이 정보"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileCard)
        profileCard.addSubview(profileImageView)
        profileCard.addSubview(childNameLabel)
        profileCard.addSubview(childAgeLabel)

        contentView.addSubview(levelCard)
        levelCard.addSubview(levelLabel)
        levelCard.addSubview(expLabel)
        levelCard.addSubview(expProgressView)

        contentView.addSubview(statsSectionLabel)
        contentView.addSubview(statsStackView)

        contentView.addSubview(ongoingMissionsSectionLabel)
        contentView.addSubview(ongoingMissionsStackView)

        contentView.addSubview(recentActivitySectionLabel)
        contentView.addSubview(recentActivityStackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        profileCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.lg)
            make.centerX.equalToSuperview()
        }

        childNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(Spacing.md)
            make.centerX.equalToSuperview()
        }

        childAgeLabel.snp.makeConstraints { make in
            make.top.equalTo(childNameLabel.snp.bottom).offset(Spacing.xxs)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Spacing.lg)
        }

        levelCard.snp.makeConstraints { make in
            make.top.equalTo(profileCard.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        levelLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(Spacing.md)
        }

        expLabel.snp.makeConstraints { make in
            make.top.equalTo(levelLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.equalToSuperview().offset(Spacing.md)
        }

        expProgressView.snp.makeConstraints { make in
            make.top.equalTo(expLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(8)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        statsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(levelCard.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(statsSectionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(100)
        }

        ongoingMissionsSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        ongoingMissionsStackView.snp.makeConstraints { make in
            make.top.equalTo(ongoingMissionsSectionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        recentActivitySectionLabel.snp.makeConstraints { make in
            make.top.equalTo(ongoingMissionsStackView.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        recentActivityStackView.snp.makeConstraints { make in
            make.top.equalTo(recentActivitySectionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }
    }

    private func loadMockData() {
        // Mock Statistics
        let stats: [(String, String, UIColor)] = [
            ("완료한 미션", "28", UIColor.kidkGreen),
            ("진행 중", "3", UIColor.kidkPink),
            ("총 보상", "56,000원", UIColor.kidkYellow)
        ]

        for (title, value, color) in stats {
            let statView = createStatView(title: title, value: value, color: color)
            statsStackView.addArrangedSubview(statView)
        }

        // Mock Ongoing Missions
        let missions: [(String, String, UIColor)] = [
            ("방 정리하기", "50%", UIColor.kidkPink),
            ("책 30페이지 읽기", "75%", UIColor.kidkPink),
            ("설거지 돕기", "30%", UIColor.kidkPink)
        ]

        for (title, progress, color) in missions {
            let missionView = createMissionView(title: title, progress: progress, color: color)
            ongoingMissionsStackView.addArrangedSubview(missionView)
        }

        // Mock Recent Activities
        let activities = [
            ("✅", "방 정리 미션 인증 제출", "2시간 전"),
            ("✅", "독서 미션 인증 제출", "5시간 전"),
            ("💰", "미션 보상 받음", "1일 전"),
            ("🎯", "새로운 미션 시작", "2일 전"),
            ("⬆️", "레벨 5 달성!", "3일 전")
        ]

        for (icon, title, time) in activities {
            let activityView = createActivityView(icon: icon, title: title, time: time)
            recentActivityStackView.addArrangedSubview(activityView)
        }
    }

    private func createStatView(title: String, value: String, color: UIColor) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "#2C2C2E")
        containerView.layer.cornerRadius = CornerRadius.medium

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .kidkFont(.s12, .regular)
        titleLabel.textColor = .kidkGray
        titleLabel.textAlignment = .center

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .kidkFont(.s20, .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center

        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)

        valueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.xs)
        }

        return containerView
    }

    private func createMissionView(title: String, progress: String, color: UIColor) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "#2C2C2E")
        containerView.layer.cornerRadius = CornerRadius.medium

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .kidkFont(.s16, .medium)
        titleLabel.textColor = .kidkTextWhite

        let progressLabel = UILabel()
        progressLabel.text = progress
        progressLabel.font = .kidkFont(.s14, .bold)
        progressLabel.textColor = color

        containerView.addSubview(titleLabel)
        containerView.addSubview(progressLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
        }

        progressLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        return containerView
    }

    private func createActivityView(icon: String, title: String, time: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: "#2C2C2E")
        containerView.layer.cornerRadius = CornerRadius.small

        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .kidkFont(.s16, .medium)
        titleLabel.textColor = .kidkTextWhite

        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .kidkFont(.s12, .regular)
        timeLabel.textColor = .kidkGray

        containerView.addSubview(iconLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(timeLabel)

        iconLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
            make.width.equalTo(30)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(Spacing.sm)
            make.top.equalToSuperview().offset(Spacing.sm)
            make.trailing.equalToSuperview().offset(-Spacing.md)
        }

        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-Spacing.sm)
        }

        containerView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        return containerView
    }
}
