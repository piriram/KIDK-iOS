import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ParentApprovalViewController: BaseViewController, NavigationChromeConfigurable {

    private let viewModel: ParentApprovalViewModel

    private let navigationHeaderView = KIDKNavigationHeaderView(title: "승인 대기")
    private let sectionHeaderView = ParentTimelineSectionHeaderView()
    private let summaryCardView = ParentTimelineCardView(accentColor: .kidkPink)

    private let pendingCountTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.text = "현재 확인이 필요한 인증"
        return label
    }()

    private let pendingCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s30, .bold)
        label.textColor = .kidkTextWhite
        label.text = "0건"
        return label
    }()

    private let pendingSummaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        label.numberOfLines = 0
        label.text = "새로운 인증이 올라오면 타임라인 순서대로 보여드려요"
        return label
    }()

    private let pendingProgressView = ParentTimelineProgressRowView()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .kidkDarkBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset.bottom = Spacing.lg
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
        label.font = .systemFont(ofSize: 58)
        label.textAlignment = .center
        return label
    }()

    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "승인 대기 인증을 모두 확인했어요"
        label.font = UIFont.kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        return label
    }()

    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "아이가 다음 미션을 인증하면\n여기 타임라인에 자동으로 추가돼요"
        label.font = UIFont.kidkFont(.s14, .regular)
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

    var prefersNavigationBarHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(navigationHeaderView)
        view.addSubview(sectionHeaderView)
        view.addSubview(summaryCardView)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        let summaryStack = UIStackView(arrangedSubviews: [pendingCountTitleLabel, pendingCountLabel, pendingSummaryLabel, pendingProgressView])
        summaryStack.axis = .vertical
        summaryStack.spacing = Spacing.xs
        summaryCardView.contentView.addSubview(summaryStack)

        emptyStateView.addSubview(emptyIconLabel)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptyMessageLabel)

        sectionHeaderView.configure(
            step: "STEP 1",
            title: "인증 승인 타임라인",
            subtitle: "가장 최근 인증부터 확인하고 바로 승인·거절할 수 있어요"
        )

        navigationHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(KIDKNavigationHeaderView.height)
        }

        sectionHeaderView.snp.makeConstraints { make in
            make.top.equalTo(navigationHeaderView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        summaryCardView.snp.makeConstraints { make in
            make.top.equalTo(sectionHeaderView.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        summaryStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(summaryCardView.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        emptyStateView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(tableView)
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
                let sortedVerifications = verifications.sorted { $0.verification.submittedDate > $1.verification.submittedDate }
                self?.verifications = sortedVerifications
                self?.tableView.reloadData()
                self?.updateEmptyState(isEmpty: sortedVerifications.isEmpty)
                self?.updateSummary(for: sortedVerifications)
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

    private func updateSummary(for verifications: [ParentApprovalViewModel.VerificationWithMission]) {
        let pendingCount = verifications.count
        pendingCountLabel.text = "\(pendingCount)건"

        if let latestDate = verifications.first?.verification.submittedDate {
            pendingSummaryLabel.text = "가장 최근 인증은 \(latestDate.formattedDateTime)에 도착했어요"
        } else {
            pendingSummaryLabel.text = "새로운 인증이 올라오면 타임라인 순서대로 보여드려요"
        }

        let progress = min(CGFloat(pendingCount) / 7.0, 1.0)
        pendingProgressView.configure(
            title: "확인 우선순위",
            valueText: pendingCount == 0 ? "여유" : "\(pendingCount)건 대기",
            progress: progress,
            tintColor: pendingCount == 0 ? .kidkGreen : .kidkPink
        )
    }

    private func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func showVerificationDetail(_ verificationWithMission: ParentApprovalViewModel.VerificationWithMission) {
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
        let showsConnector = indexPath.row < verifications.count - 1
        cell.configure(
            with: verificationWithMission.verification,
            missionTitle: verificationWithMission.missionTitle,
            showsConnector: showsConnector
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
        return 156
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

    func configure(with verification: MissionVerification, missionTitle: String, showsConnector: Bool) {
        cardView.configure(with: verification, missionTitle: missionTitle, showsConnector: showsConnector)
    }
}
