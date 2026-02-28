import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MissionViewController: BaseViewController, NavigationChromeConfigurable {

    private let viewModel: MissionViewModel

    private var missions: [Mission] = []
    private var collapseStates: [Bool] = []

    private let collapseButtonTappedSubject = PublishSubject<Int>()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MissionCardCell.self, forCellReuseIdentifier: MissionCardCell.identifier)
        return tableView
    }()
    
    private lazy var navigationHeaderView = KIDKNavigationHeaderView(
        title: Strings.Mission.title,
        rightButton: .init(systemImageName: "line.3.horizontal", accessibilityLabel: "메뉴", action: {})
    )
    
    private let goToKIDKCityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.Mission.goToKIDKCity, for: .normal)
        button.titleLabel?.font = .kidkSubtitle
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.extraLarge
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Spacing.md, bottom: 0, right: Spacing.md)
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
    
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Mission.ongoingSavingMissions
        label.font = .kidkBody
        label.textColor = .kidkTextWhite
        return label
    }()

    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .kidkTextWhite.withAlphaComponent(0.6)
        return button
    }()
    
    init(viewModel: MissionViewModel) {
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
        view.addSubview(goToKIDKCityButton)
        goToKIDKCityButton.addSubview(arrowImageView)

        view.addSubview(sectionHeaderView)
        sectionHeaderView.addSubview(sectionTitleLabel)
        sectionHeaderView.addSubview(infoButton)

        view.addSubview(tableView)

        navigationHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(KIDKNavigationHeaderView.height)
        }

        goToKIDKCityButton.snp.makeConstraints { make in
            make.top.equalTo(navigationHeaderView.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(64)
        }

        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        sectionHeaderView.snp.makeConstraints { make in
            make.top.equalTo(goToKIDKCityButton.snp.bottom).offset(Spacing.lg)
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

        tableView.snp.makeConstraints { make in
            make.top.equalTo(sectionHeaderView.snp.bottom).offset(9)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        let input = MissionViewModel.Input(
            goToKIDKCityTapped: goToKIDKCityButton.rx.tap.asObservable(),
            missionInfoTapped: infoButton.rx.tap.asObservable(),
            collapseButtonTapped: collapseButtonTappedSubject.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.missions
            .drive(onNext: { [weak self] missions in
                self?.missions = missions
                self?.sectionTitleLabel.text = missions.isEmpty ? "저축 미션" : "저축 미션 현황"
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.collapseStates
            .drive(onNext: { [weak self] states in
                guard let self = self else { return }
                let previousStates = self.collapseStates
                self.collapseStates = states

                // Find which index changed and animate only that cell
                if previousStates.count == states.count {
                    for (index, (previous, current)) in zip(previousStates, states).enumerated() {
                        if previous != current {
                            self.animateCellHeightChange(at: index)
                            break
                        }
                    }
                }
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive()
            .disposed(by: disposeBag)
    }

    private func animateCellHeightChange(at index: Int) {
        tableView.performBatchUpdates({
            // Force the table view to recalculate the cell height
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension MissionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(missions.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MissionCardCell.identifier, for: indexPath) as? MissionCardCell else {
            return UITableViewCell()
        }

        let mission = missions.indices.contains(indexPath.row) ? missions[indexPath.row] : nil
        let isCollapsed = indexPath.row < collapseStates.count ? collapseStates[indexPath.row] : false

        cell.configure(with: mission, isCollapsed: isCollapsed)

        cell.collapseButtonTapped
            .subscribe(onNext: { [weak self] in
                guard self?.missions.indices.contains(indexPath.row) == true else { return }
                self?.collapseButtonTappedSubject.onNext(indexPath.row)
            })
            .disposed(by: cell.disposeBag)

        cell.verifyButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let mission else { return }
                self?.showVerificationScreen(for: mission)
            })
            .disposed(by: cell.disposeBag)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension MissionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if missions.isEmpty { return 460 }
        let isCollapsed = indexPath.row < collapseStates.count ? collapseStates[indexPath.row] : false
        return isCollapsed ? 84 : 500
    }

    // MARK: - Navigation

    private func showVerificationScreen(for mission: Mission) {
        let viewModel = MissionVerificationViewModel(mission: mission)
        let verificationVC = MissionVerificationViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: verificationVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}
