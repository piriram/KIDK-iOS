import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MissionCreationViewController: BaseViewController {
    
    let missionCreated = PublishSubject<Mission>()
    let previousTapped = PublishSubject<Void>()
    
    private let viewModel: MissionCreationViewModel
    private let missionType: MissionType
    
    private let goalTitleRelay = BehaviorRelay<String>(value: "")
    private let targetDateRelay = BehaviorRelay<Date?>(value: nil)
    private let rewardAmountRelay = BehaviorRelay<Int>(value: 500)
    private let participantIdsRelay = BehaviorRelay<[String]>(value: [])

    private enum Layout {
        static let horizontalInset = Spacing.md
        static let compactGap: CGFloat = 16
        static let sectionGap: CGFloat = 20
        static let cardHeight: CGFloat = 72
        static let inputHeight: CGFloat = 56
        static let amountHeight: CGFloat = 88
        static let avatarSize: CGFloat = 60
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "목표를 자세히 설정해봐요"
        label.font = .kidkTitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let schoolImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.text = "함께하는 친구"
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let friendsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let friend1ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 1.2
        imageView.layer.borderColor = UIColor(hex: "#1F1F27").cgColor
        imageView.backgroundColor = UIColor(hex: "#25252D")
        imageView.clipsToBounds = true
        return imageView
    }()    
    private let friend2ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 1.2
        imageView.layer.borderColor = UIColor(hex: "#1F1F27").cgColor
        imageView.backgroundColor = UIColor(hex: "#25252D")
        imageView.clipsToBounds = true
        return imageView
    }()    
    private let friend3ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 1.2
        imageView.layer.borderColor = UIColor(hex: "#1F1F27").cgColor
        imageView.backgroundColor = UIColor(hex: "#25252D")
        imageView.clipsToBounds = true
        return imageView
    }()    
    private let addFriendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .kidkTextWhite
        button.backgroundColor = UIColor(hex: "#25252D")
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 1.2
        button.layer.borderColor = UIColor(hex: "#1F1F27").cgColor
        return button
    }()
    
    private let dailyMissionLabel: UILabel = {
        let label = UILabel()
        label.text = "매일 미션"
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let missionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2F2F36")
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()
    
    private let missionIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        view.layer.cornerRadius = 12
        return view
    }()

    private let missionIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let missionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "영상을 시청한 후 퀴즈를 풀어보세요",
            size: .s16,
            weight: .semibold,
            color: .kidkTextWhite,
            lineHeight: 120
        )
        label.numberOfLines = 1
        return label
    }()
    
    private let goalSettingLabel: UILabel = {
        let label = UILabel()
        label.text = "목표를 설정해 보세요"
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let goalInputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2F2F36")
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()    
    private let goalTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "여름방학 놀이공원 가기"
        textField.font = .kidkBody
        textField.textColor = .kidkTextWhite
        textField.attributedPlaceholder = NSAttributedString(
            string: "여름방학 놀이공원 가기",
            attributes: [.foregroundColor: UIColor.kidkGray]
        )
        return textField
    }()
    
    private let dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("12/30", for: .normal)
        button.setTitleColor(.kidkGray, for: .normal)
        button.titleLabel?.font = .kidkBody
        return button
    }()
    
    private let amountSettingLabel: UILabel = {
        let label = UILabel()
        label.text = "용돈을 설정해 보세요"
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let amountContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2F2F36")
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        return view
    }()    
    private let decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .kidkPink
        return button
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "500"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .kidkPink
        label.textAlignment = .center
        return label
    }()
    
    private let increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .kidkPink
        return button
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "원"
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let previousButton = KIDKButton(
        title: "이전으로",
        backgroundColor: UIColor(hex: "#2C2C2E"),
        titleColor: .kidkTextWhite
    )
    
    private let nextButton = KIDKButton(
        title: "다음",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite
    )
    
    init(viewModel: MissionCreationViewModel) {
        self.viewModel = viewModel
        self.missionType = viewModel.missionType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        configureStaticAssets()
        configureMissionContent()
        bindViewModel()
        bindUIActions()
    }

    private func setupNavigationBar() {
        title = "미션 만들기"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(schoolImageView)
        contentView.addSubview(participantsLabel)
        contentView.addSubview(friendsStackView)
        
        friendsStackView.addArrangedSubview(friend1ImageView)
        friendsStackView.addArrangedSubview(friend2ImageView)
        friendsStackView.addArrangedSubview(friend3ImageView)
        friendsStackView.addArrangedSubview(addFriendButton)
        
        contentView.addSubview(dailyMissionLabel)
        contentView.addSubview(missionCardView)
        missionCardView.addSubview(missionIconContainer)
        missionIconContainer.addSubview(missionIconImageView)
        missionCardView.addSubview(missionDescriptionLabel)
        
        contentView.addSubview(goalSettingLabel)
        contentView.addSubview(goalInputContainer)
        goalInputContainer.addSubview(goalTextField)
        goalInputContainer.addSubview(dateButton)
        
        contentView.addSubview(amountSettingLabel)
        contentView.addSubview(amountContainer)
        amountContainer.addSubview(decreaseButton)
        amountContainer.addSubview(amountLabel)
        amountContainer.addSubview(increaseButton)
        amountContainer.addSubview(currencyLabel)
        
        view.addSubview(previousButton)
        view.addSubview(nextButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(previousButton.snp.top).offset(-Spacing.xs)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }

        schoolImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.compactGap)
            make.centerX.equalToSuperview()
            make.width.equalTo(230)
            make.height.equalTo(136)
        }

        participantsLabel.snp.makeConstraints { make in
            make.top.equalTo(schoolImageView.snp.bottom).offset(Spacing.md)
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
        }

        friendsStackView.snp.makeConstraints { make in
            make.top.equalTo(participantsLabel.snp.bottom).offset(Spacing.sm)
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().offset(-Layout.horizontalInset)
            make.height.equalTo(Layout.avatarSize)
        }

        friend1ImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Layout.avatarSize)
        }

        friend2ImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Layout.avatarSize)
        }

        friend3ImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Layout.avatarSize)
        }

        addFriendButton.snp.makeConstraints { make in
            make.width.height.equalTo(Layout.avatarSize)
        }

        dailyMissionLabel.snp.makeConstraints { make in
            make.top.equalTo(friendsStackView.snp.bottom).offset(Spacing.lg)
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
        }

        missionCardView.snp.makeConstraints { make in
            make.top.equalTo(dailyMissionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.cardHeight)
        }

        missionIconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }

        missionIconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        missionDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(missionIconContainer.snp.trailing).offset(Spacing.sm)
            make.trailing.lessThanOrEqualToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
        }

        goalSettingLabel.snp.makeConstraints { make in
            make.top.equalTo(missionCardView.snp.bottom).offset(Layout.sectionGap)
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
        }

        goalInputContainer.snp.makeConstraints { make in
            make.top.equalTo(goalSettingLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.inputHeight)
        }

        goalTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.trailing.equalTo(dateButton.snp.leading).offset(-Spacing.xs)
            make.centerY.equalToSuperview()
        }

        dateButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
        }

        amountSettingLabel.snp.makeConstraints { make in
            make.top.equalTo(goalInputContainer.snp.bottom).offset(Layout.sectionGap)
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
        }

        amountContainer.snp.makeConstraints { make in
            make.top.equalTo(amountSettingLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.height.equalTo(Layout.amountHeight)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        decreaseButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.xl)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        increaseButton.snp.makeConstraints { make in
            make.trailing.equalTo(currencyLabel.snp.leading).offset(-Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        currencyLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.xl)
            make.centerY.equalToSuperview()
        }
        
        previousButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.horizontalInset)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.xs)
            make.height.equalTo(56)
            make.width.equalTo(120)
        }

        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(previousButton.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview().offset(-Layout.horizontalInset)
            make.centerY.equalTo(previousButton)
            make.height.equalTo(56)
        }
    }
    
    private func configureMissionContent() {
        switch missionType {
        case .video:
            missionIconImageView.image = resolvedImage(named: "kidk_mission_video", fallbackSystemName: "play.rectangle.fill")
            missionIconImageView.tintColor = missionIconImageView.image?.isSymbolImage == true ? .kidkPink : nil
            applyMissionDescription("영상을 시청한 후 퀴즈를 풀어보세요")

        case .study:
            missionIconImageView.image = resolvedImage(named: "kidk_mission_study", fallbackSystemName: "pencil")
            missionIconImageView.tintColor = missionIconImageView.image?.isSymbolImage == true ? .kidkPink : nil
            applyMissionDescription("1시간씩 수학 공부를 하기")

        case .quiz:
            missionIconImageView.image = resolvedImage(named: "kidk_mission_quiz", fallbackSystemName: "character.book.closed")
            missionIconImageView.tintColor = missionIconImageView.image?.isSymbolImage == true ? .kidkPink : nil
            applyMissionDescription("30개씩 영어 단어를 외우기")

        case .custom:
            dailyMissionLabel.text = "미션 내용"
            missionCardView.isHidden = true

        case .savings:
            missionIconImageView.image = resolvedImage(named: "kidk_mission_savings", fallbackSystemName: "wallet.pass.fill")
            missionIconImageView.tintColor = missionIconImageView.image?.isSymbolImage == true ? .kidkPink : nil
            applyMissionDescription("목표 금액을 저축해보세요")
        }
    }
    
    private func applyMissionDescription(_ text: String) {
        missionDescriptionLabel.applyTextStyle(
            text: text,
            size: .s16,
            weight: .semibold,
            color: .kidkTextWhite,
            lineHeight: 120
        )
    }

    private func configureStaticAssets() {
        schoolImageView.image = resolvedImage(named: "kidk_city_school", fallbackSystemName: "building.2.fill")
        schoolImageView.tintColor = schoolImageView.image?.isSymbolImage == true ? .kidkGray : nil

        applyFriendAsset(to: friend1ImageView, assetName: "kidk_friend_avatar_1")
        applyFriendAsset(to: friend2ImageView, assetName: "kidk_friend_avatar_2")
        applyFriendAsset(to: friend3ImageView, assetName: "kidk_friend_avatar_3")

        if let addFriendAsset = UIImage(named: "kidk_friend_add_icon") {
            addFriendButton.setImage(addFriendAsset, for: .normal)
            addFriendButton.tintColor = nil
        } else {
            addFriendButton.setImage(UIImage(systemName: "person.badge.plus"), for: .normal)
            addFriendButton.tintColor = .kidkPink
        }
    }

    private func applyFriendAsset(to imageView: UIImageView, assetName: String) {
        if let image = UIImage(named: assetName) ?? UIImage(named: "kidk_profile_one") {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            return
        }

        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .kidkGray
        imageView.contentMode = .center
    }

    private func resolvedImage(named assetName: String, fallbackSystemName: String) -> UIImage {
        if let image = UIImage(named: assetName) {
            return image
        }

        return UIImage(systemName: fallbackSystemName) ?? UIImage()
    }

    private func bindViewModel() {
        let input = MissionCreationViewModel.Input(
            goalTitle: goalTitleRelay.asObservable(),
            targetDate: targetDateRelay.asObservable(),
            rewardAmount: rewardAmountRelay.asObservable(),
            participantIds: participantIdsRelay.asObservable(),
            createTapped: nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isCreateEnabled
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.missionCreated
            .emit(to: missionCreated)
            .disposed(by: disposeBag)
        
        output.createError
            .emit(onNext: { [weak self] error in
                self?.showError(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .asDriver()
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindUIActions() {
        goalTextField.rx.text.orEmpty
            .bind(to: goalTitleRelay)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.decreaseAmount()
            })
            .disposed(by: disposeBag)
        
        increaseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.increaseAmount()
            })
            .disposed(by: disposeBag)
        
        previousButton.rx.tap
            .bind(to: previousTapped)
            .disposed(by: disposeBag)
        
        dateButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showDatePicker()
            })
            .disposed(by: disposeBag)
    }
    
    private func decreaseAmount() {
        let currentAmount = rewardAmountRelay.value
        let newAmount = max(0, currentAmount - 100)
        rewardAmountRelay.accept(newAmount)
        amountLabel.text = "\(newAmount)"
    }
    
    private func increaseAmount() {
        let currentAmount = rewardAmountRelay.value
        let newAmount = currentAmount + 100
        rewardAmountRelay.accept(newAmount)
        amountLabel.text = "\(newAmount)"
    }
    
    private func showDatePicker() {
        let alert = UIAlertController(title: "목표 날짜 선택", message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        
        if let currentDate = targetDateRelay.value {
            datePicker.date = currentDate
        }
        
        let containerView = UIView()
        containerView.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(200)
        }
        
        alert.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        let selectAction = UIAlertAction(title: "선택", style: .default) { [weak self] _ in
            let selectedDate = datePicker.date
            self?.targetDateRelay.accept(selectedDate)
            self?.dateButton.setTitle(selectedDate.formattedMonthDay, for: .normal)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(selectAction)
        alert.addAction(cancelAction)
        
        let height: CGFloat = 350
        let heightConstraint = NSLayoutConstraint(
            item: alert.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: height
        )
        alert.view.addConstraint(heightConstraint)
        
        present(alert, animated: true)
    }
}
