//
//  SavingsViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SavingsViewController: BaseViewController {

    private let viewModel: SavingsViewModel

    private var savingsGoals: [SavingsGoal] = []

    private let viewDidLoadSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    private let filterSubject = BehaviorSubject<SavingsViewModel.SavingsFilter>(value: .all)

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        return view
    }()

    private let navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "내 저금통"
        label.font = .kidkFont(.s24, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private lazy var summaryView: SavingsSummaryView = {
        let view = SavingsSummaryView()
        return view
    }()

    private let filterSegmentedControl: UISegmentedControl = {
        let items = ["전체", "진행 중", "완료"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([.foregroundColor: UIColor.kidkTextWhite], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.kidkDarkBackground], for: .selected)
        control.selectedSegmentTintColor = .kidkPink
        return control
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SavingsGoalCell.self, forCellReuseIdentifier: SavingsGoalCell.identifier)
        tableView.isScrollEnabled = false
        return tableView
    }()

    private lazy var emptyStateView: EmptySavingsView = {
        let view = EmptySavingsView()
        view.isHidden = true
        return view
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ 새 저축 목표 만들기", for: .normal)
        button.titleLabel?.font = .kidkFont(.s16, .bold)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.large
        button.layer.shadowColor = UIColor.kidkPink.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        return button
    }()

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
        viewDidLoadSubject.onNext(())
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(navigationBar)
        navigationBar.addSubview(titleLabel)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(summaryView)
        contentView.addSubview(filterSegmentedControl)
        contentView.addSubview(tableView)
        contentView.addSubview(emptyStateView)

        view.addSubview(createButton)

        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(54)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.lg)
            make.centerY.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(createButton.snp.top).offset(-Spacing.md)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        summaryView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        filterSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(summaryView.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(32)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterSegmentedControl.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }

        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(filterSegmentedControl.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(400)
        }

        createButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.md)
            make.height.equalTo(56)
        }
    }

    private func bind() {
        let input = SavingsViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            refreshTriggered: refreshSubject.asObservable(),
            filterSelected: filterSegmentedControl.rx.selectedSegmentIndex
                .map { index -> SavingsViewModel.SavingsFilter in
                    switch index {
                    case 1: return .inProgress
                    case 2: return .completed
                    default: return .all
                    }
                }
                .asObservable(),
            createGoalTapped: Observable.merge(
                createButton.rx.tap.asObservable(),
                emptyStateView.createButtonTapped
            )
        )

        let output = viewModel.transform(input: input)

        output.savingsGoals
            .drive(onNext: { [weak self] goals in
                self?.savingsGoals = goals
                self?.updateTableViewHeight()
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.isEmpty
            .drive(onNext: { [weak self] isEmpty in
                self?.tableView.isHidden = isEmpty
                self?.emptyStateView.isHidden = !isEmpty
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            output.totalSavings.asObservable(),
            output.monthlyContribution.asObservable(),
            output.savingsRate.asObservable()
        )
        .subscribe(onNext: { [weak self] total, monthly, rate in
            self?.summaryView.configure(total: total, monthly: monthly, rate: rate)
        })
        .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)
    }

    private func updateTableViewHeight() {
        let cellHeight: CGFloat = 120
        let spacing: CGFloat = 12
        let totalHeight = CGFloat(savingsGoals.count) * (cellHeight + spacing)

        tableView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
    }
}

extension SavingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savingsGoals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SavingsGoalCell.identifier, for: indexPath) as? SavingsGoalCell else {
            return UITableViewCell()
        }

        let goal = savingsGoals[indexPath.row]
        cell.configure(with: goal)

        return cell
    }
}

extension SavingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let goal = savingsGoals[indexPath.row]
        debugLog("Selected goal: \(goal.name)")
    }
}
