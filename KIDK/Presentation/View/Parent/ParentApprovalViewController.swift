//
//  ParentApprovalViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ParentApprovalViewController: BaseViewController {

    private let viewModel: ParentApprovalViewModel

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .kidkDarkBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    private let refreshControl = UIRefreshControl()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

    private let emptyIconLabel: UILabel = {
        let label = UILabel()
        label.text = "✅"
        label.font = .systemFont(ofSize: 64)
        label.textAlignment = .center
        return label
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "승인 대기 중인 인증이 없어요"
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        return label
    }()

    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "아이가 미션을 인증하면\n여기에 표시됩니다"
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private var verifications: [ParentApprovalViewModel.VerificationWithMission] = []

    init(viewModel: ParentApprovalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bind()
    }

    private func setupNavigationBar() {
        title = "승인 대기"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        emptyStateView.addSubview(emptyIconLabel)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptyMessageLabel)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        emptyStateView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
        }

        emptyIconLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyIconLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview()
        }

        emptyMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VerificationCardCell.self, forCellReuseIdentifier: VerificationCardCell.identifier)

        refreshControl.tintColor = .kidkPink
        tableView.refreshControl = refreshControl
    }

    private func bind() {
        let verificationSelected = tableView.rx.itemSelected
            .do(onNext: { [weak tableView] indexPath in
                tableView?.deselectRow(at: indexPath, animated: true)
            })
            .asObservable()

        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .asObservable()

        let input = ParentApprovalViewModel.Input(
            viewWillAppear: viewWillAppear,
            verificationSelected: verificationSelected,
            refreshTriggered: refreshControl.rx.controlEvent(.valueChanged).asObservable()
        )

        let output = viewModel.transform(input: input)

        output.verifications
            .drive(onNext: { [weak self] (verifications: [ParentApprovalViewModel.VerificationWithMission]) in
                self?.verifications = verifications
                self?.tableView.reloadData()
                self?.updateEmptyState(isEmpty: verifications.isEmpty)
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] (isLoading: Bool) in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        output.error
            .compactMap { $0 }
            .drive(onNext: { [weak self] error in
                self?.showAlert(title: "오류", message: error)
            })
            .disposed(by: disposeBag)

        output.selectedVerification
            .drive(onNext: { [weak self] verificationWithMission in
                self?.showVerificationDetail(verificationWithMission)
            })
            .disposed(by: disposeBag)
    }

    private func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func showVerificationDetail(_ verificationWithMission: ParentApprovalViewModel.VerificationWithMission) {
        // For Phase 1, we'll pass the missionRepository
        // In the future, this should come from a coordinator
        guard let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") else {
            showAlert(title: "오류", message: "사용자 정보를 찾을 수 없어요")
            return
        }

        let missionRepository = MissionRepository(currentUserId: currentUserId)
        let viewModel = VerificationDetailViewModel(
            verification: verificationWithMission.verification,
            missionTitle: verificationWithMission.missionTitle,
            missionRepository: missionRepository
        )
        let detailVC = VerificationDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ParentApprovalViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return verifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: VerificationCardCell.identifier,
            for: indexPath
        ) as? VerificationCardCell else {
            return UITableViewCell()
        }

        let verificationWithMission = verifications[indexPath.row]
        cell.configure(
            with: verificationWithMission.verification,
            missionTitle: verificationWithMission.missionTitle
        )
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ParentApprovalViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - VerificationCardCell

final class VerificationCardCell: UITableViewCell {

    static let identifier = "VerificationCardCell"

    private let cardView = VerificationCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(cardView)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.xs)
        }
    }

    func configure(with verification: MissionVerification, missionTitle: String) {
        cardView.configure(with: verification, missionTitle: missionTitle)
    }
}
