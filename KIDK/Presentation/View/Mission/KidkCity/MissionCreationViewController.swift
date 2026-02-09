//
//  MissionCreationViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/16/25.
//

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
        imageView.image = UIImage(named: "kidk_city_school")
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
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let friend1ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_friend_avatar_1")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let friend2ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_friend_avatar_2")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let friend3ImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_friend_avatar_3")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let addFriendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .kidkTextWhite
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = 30
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
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()
    
    private let missionIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kidk_mission_video")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let missionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "영상을 시청한 후 퀴즈를 풀어보세요"
        label.font = .kidkBody
        label.textColor = .kidkTextWhite
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
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.medium
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
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.medium
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
        setupUI()
        configureMissionContent()
        bindViewModel()
        bindUIActions()
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
        missionCardView.addSubview(missionIconImageView)
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
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(previousButton.snp.top).offset(-Spacing.md)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
        }
        
        schoolImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xl)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(120)
        }
        
        participantsLabel.snp.makeConstraints { make in
            make.top.equalTo(schoolImageView.snp.bottom).offset(Spacing.xl)
            make.leading.equalToSuperview().offset(Spacing.xl)
        }
        
        friendsStackView.snp.makeConstraints { make in
            make.top.equalTo(participantsLabel.snp.bottom).offset(Spacing.md)
            make.leading.equalToSuperview().offset(Spacing.xl)
            make.height.equalTo(60)
        }
        
        friend1ImageView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        friend2ImageView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        friend3ImageView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        addFriendButton.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
        
        dailyMissionLabel.snp.makeConstraints { make in
            make.top.equalTo(friendsStackView.snp.bottom).offset(Spacing.xl)
            make.leading.equalToSuperview().offset(Spacing.xl)
        }
        
        missionCardView.snp.makeConstraints { make in
            make.top.equalTo(dailyMissionLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(60)
        }
        
        missionIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        missionDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(missionIconImageView.snp.trailing).offset(Spacing.md)
            make.centerY.equalToSuperview()
        }
        
        goalSettingLabel.snp.makeConstraints { make in
            make.top.equalTo(missionCardView.snp.bottom).offset(Spacing.xl)
            make.leading.equalToSuperview().offset(Spacing.xl)
        }
        
        goalInputContainer.snp.makeConstraints { make in
            make.top.equalTo(goalSettingLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(50)
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
            make.top.equalTo(goalInputContainer.snp.bottom).offset(Spacing.xl)
            make.leading.equalToSuperview().offset(Spacing.xl)
        }
        
        amountContainer.snp.makeConstraints { make in
            make.top.equalTo(amountSettingLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.xl)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
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
            make.leading.equalToSuperview().offset(Spacing.xl)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Spacing.md)
            make.height.equalTo(56)
            make.width.equalTo(120)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(previousButton.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview().offset(-Spacing.xl)
            make.centerY.equalTo(previousButton)
            make.height.equalTo(56)
        }
    }
    
    private func configureMissionContent() {
        switch missionType {
        case .video:
            missionIconImageView.image = UIImage(named: "kidk_mission_video")
            missionDescriptionLabel.text = "영상을 시청한 후 퀴즈를 풀어보세요"
            
        case .study:
            missionIconImageView.image = UIImage(named: "kidk_mission_study")
            missionDescriptionLabel.text = "1시간씩 수학 공부를 하기"
            
        case .quiz:
            missionIconImageView.image = UIImage(named: "kidk_mission_quiz")
            missionDescriptionLabel.text = "30개씩 영어 단어를 외우기"
            
        case .custom:
            dailyMissionLabel.text = "미션 내용"
            missionCardView.isHidden = true
            
        case .savings:
            missionIconImageView.image = UIImage(named: "kidk_mission_savings")
            missionDescriptionLabel.text = "목표 금액을 저축해보세요"
        }
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
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            self?.dateButton.setTitle(formatter.string(from: selectedDate), for: .normal)
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
