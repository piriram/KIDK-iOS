//
//  SavingsViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/21/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SavingsViewController: BaseViewController {

    private let viewModel: SavingsViewModel

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView = UIView()

    private let headerView = SavingsHeaderView()

    private let inProgressSection = SectionHeaderView()
    private let inProgressStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.md
        return stackView
    }()

    private let completedSection = SectionHeaderView()
    private let completedStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.md
        return stackView
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "banknote")
        imageView.tintColor = .kidkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "아직 저축 목표가 없어요",
            size: .s20,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        label.textAlignment = .center
        return label
    }()

    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "첫 저축 목표를 만들어보세요!",
            size: .s16,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        label.textAlignment = .center
        return label
    }()

    private let addGoalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저축 목표 만들기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = 12
        return button
    }()

    private let refreshControl = UIRefreshControl()

    init(viewModel: SavingsViewModel) {
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
        title = "내 저금통"
        view.backgroundColor = UIColor(hex: "#1C1C1E")

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerView)
        contentView.addSubview(inProgressSection)
        contentView.addSubview(inProgressStackView)
        contentView.addSubview(completedSection)
        contentView.addSubview(completedStackView)
        contentView.addSubview(emptyStateView)

        emptyStateView.addSubview(emptyImageView)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptyMessageLabel)
        emptyStateView.addSubview(addGoalButton)

        scrollView.refreshControl = refreshControl

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        inProgressSection.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        inProgressStackView.snp.makeConstraints { make in
            make.top.equalTo(inProgressSection.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        completedSection.snp.makeConstraints { make in
            make.top.equalTo(inProgressStackView.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        completedStackView.snp.makeConstraints { make in
            make.top.equalTo(completedSection.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }

        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview()
        }

        emptyMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview()
        }

        addGoalButton.snp.makeConstraints { make in
            make.top.equalTo(emptyMessageLabel.snp.bottom).offset(Spacing.lg)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
            make.bottom.equalToSuperview()
        }

        inProgressSection.configure(title: "진행 중인 목표", subtitle: nil)
        completedSection.configure(title: "달성한 목표", subtitle: nil)
    }

    private func bind() {
        let viewDidLoadTrigger = rx.sentMessage(#selector(UIViewController.viewDidLoad))
            .map { _ in () }
            .asObservable()

        let goalSelectedTrigger = PublishRelay<SavingsGoal>()

        let input = SavingsViewModel.Input(
            viewDidLoad: viewDidLoadTrigger,
            goalSelected: goalSelectedTrigger.asObservable(),
            refreshTrigger: refreshControl.rx.controlEvent(.valueChanged).asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        output.stats
            .drive(onNext: { [weak self] stats in
                self?.headerView.configure(with: stats)
            })
            .disposed(by: disposeBag)

        output.inProgressGoals
            .drive(onNext: { [weak self] goals in
                self?.updateInProgressGoals(goals, goalSelectedRelay: goalSelectedTrigger)
            })
            .disposed(by: disposeBag)

        output.completedGoals
            .drive(onNext: { [weak self] goals in
                self?.updateCompletedGoals(goals, goalSelectedRelay: goalSelectedTrigger)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            output.inProgressGoals.asObservable(),
            output.completedGoals.asObservable()
        )
        .subscribe(onNext: { [weak self] inProgress, completed in
            let isEmpty = inProgress.isEmpty && completed.isEmpty
            self?.emptyStateView.isHidden = !isEmpty
            self?.inProgressSection.isHidden = isEmpty
            self?.completedSection.isHidden = isEmpty
        })
        .disposed(by: disposeBag)

        output.error
            .drive(onNext: { [weak self] error in
                self?.showError(message: error)
            })
            .disposed(by: disposeBag)

        addGoalButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAlert(title: "준비중", message: "저축 목표 만들기 기능은 곧 추가될 예정입니다.")
            })
            .disposed(by: disposeBag)
    }

    private func updateInProgressGoals(_ goals: [SavingsGoal], goalSelectedRelay: PublishRelay<SavingsGoal>) {
        inProgressStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if goals.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.applyTextStyle(
                text: "진행 중인 저축 목표가 없습니다",
                size: .s16,
                weight: .regular,
                color: .kidkGray,
                lineHeight: 140
            )
            emptyLabel.textAlignment = .center
            inProgressStackView.addArrangedSubview(emptyLabel)
            emptyLabel.snp.makeConstraints { make in
                make.height.equalTo(60)
            }
        } else {
            goals.forEach { goal in
                let cardView = SavingsGoalCardView()
                cardView.configure(with: goal)
                cardView.cardTapped
                    .bind(to: goalSelectedRelay)
                    .disposed(by: disposeBag)
                inProgressStackView.addArrangedSubview(cardView)
            }
        }
    }

    private func updateCompletedGoals(_ goals: [SavingsGoal], goalSelectedRelay: PublishRelay<SavingsGoal>) {
        completedStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if goals.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.applyTextStyle(
                text: "달성한 저축 목표가 없습니다",
                size: .s16,
                weight: .regular,
                color: .kidkGray,
                lineHeight: 140
            )
            emptyLabel.textAlignment = .center
            completedStackView.addArrangedSubview(emptyLabel)
            emptyLabel.snp.makeConstraints { make in
                make.height.equalTo(60)
            }
        } else {
            goals.forEach { goal in
                let cardView = SavingsGoalCardView()
                cardView.configure(with: goal)
                cardView.cardTapped
                    .bind(to: goalSelectedRelay)
                    .disposed(by: disposeBag)
                completedStackView.addArrangedSubview(cardView)
            }
        }
    }
}

