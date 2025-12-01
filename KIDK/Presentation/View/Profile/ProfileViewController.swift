//
//  ProfileViewController.swift
//  KIDK
//
//  Created by KIDK on 12/02/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ProfileViewController: BaseViewController {

    private let viewModel: ProfileViewModel

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "내 프로필",
            size: .s24,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let profileImageContainer: UIView = {
        let view = UIView()
        return view
    }()

    private let profileImageView = ProfileImageView(
        assetName: "kidk_profile_one",
        size: 100,
        bgColor: .white,
        iconRatio: 0.7
    )

    private let editImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        return button
    }()

    // Name Field
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "이름",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름을 입력하세요"
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.backgroundColor = .cardBackground
        textField.layer.cornerRadius = CornerRadius.medium
        textField.autocapitalizationType = .words

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        return textField
    }()

    // Birthdate Field
    private let birthdateLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "생년월일",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let birthdateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "날짜를 선택하세요"
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.backgroundColor = .cardBackground
        textField.layer.cornerRadius = CornerRadius.medium
        textField.tintColor = .clear // 커서 숨김

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        return textField
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        picker.maximumDate = Date()

        // 기본값: 10년 전
        var components = DateComponents()
        components.year = -10
        if let defaultDate = Calendar.current.date(byAdding: components, to: Date()) {
            picker.date = defaultDate
        }

        return picker
    }()

    // Phone Field
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "전화번호",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "010-0000-0000"
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.backgroundColor = .cardBackground
        textField.layer.cornerRadius = CornerRadius.medium
        textField.keyboardType = .phonePad

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        return textField
    }()

    // User Type Label
    private let userTypeLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "계정 유형",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let userTypeValueLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "아이",
            size: .s16,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        return label
    }()

    private lazy var saveButton = KIDKButton(
        title: "저장",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )

    // MARK: - Init

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupDatePicker()
        setupPhoneFormatter()
        bind()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageContainer)
        profileImageContainer.addSubview(profileImageView)
        profileImageContainer.addSubview(editImageButton)

        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(birthdateLabel)
        contentView.addSubview(birthdateTextField)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(phoneTextField)
        contentView.addSubview(userTypeLabel)
        contentView.addSubview(userTypeValueLabel)
        contentView.addSubview(saveButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        profileImageContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xl)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }

        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        editImageButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.trailing.bottom.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageContainer.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }

        birthdateLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        birthdateTextField.snp.makeConstraints { make in
            make.top.equalTo(birthdateLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }

        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(birthdateTextField.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }

        userTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        userTypeValueLabel.snp.makeConstraints { make in
            make.top.equalTo(userTypeLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(userTypeValueLabel.snp.bottom).offset(Spacing.xxl)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-Spacing.lg)
        }
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "프로필"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.kidkTextWhite
        ]
    }

    private func setupDatePicker() {
        // DatePicker를 TextField의 inputView로 설정
        birthdateTextField.inputView = datePicker

        // Toolbar 추가 (완료 버튼)
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(datePickerDone))
        doneButton.tintColor = .kidkPink

        toolbar.items = [flexSpace, doneButton]
        birthdateTextField.inputAccessoryView = toolbar

        // DatePicker 값 변경 시
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
    }

    private func setupPhoneFormatter() {
        phoneTextField.delegate = self
    }

    @objc private func datePickerChanged() {
        updateBirthdateText()
    }

    @objc private func datePickerDone() {
        updateBirthdateText()
        birthdateTextField.resignFirstResponder()
    }

    private func updateBirthdateText() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        birthdateTextField.text = formatter.string(from: datePicker.date)
    }

    // MARK: - Bind

    private func bind() {
        let viewDidLoad = rx.sentMessage(#selector(UIViewController.viewDidLoad))
            .map { _ in () }
            .asObservable()

        // DatePicker의 날짜를 YYYY-MM-DD 형식으로 변환
        let birthdateText = datePicker.rx.date
            .map { [weak self] date -> String in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: date)
            }
            .asObservable()

        let input = ProfileViewModel.Input(
            viewDidLoad: viewDidLoad,
            nameText: nameTextField.rx.text.orEmpty.asObservable(),
            birthdateText: birthdateText.map { Optional($0) },
            phoneText: phoneTextField.rx.text.asObservable(),
            profileImageSelected: .never(), // TODO: 이미지 선택 기능 추가
            saveButtonTapped: saveButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        // 프로필 정보 표시
        output.userProfile
            .drive(onNext: { [weak self] user in
                self?.nameTextField.text = user.name
                self?.userTypeValueLabel.text = user.userType == .parent ? "부모" : "아이"

                // birthdate 표시
                if let birthdate = user.birthdate {
                    self?.datePicker.date = birthdate
                    let displayFormatter = DateFormatter()
                    displayFormatter.dateFormat = "yyyy년 MM월 dd일"
                    self?.birthdateTextField.text = displayFormatter.string(from: birthdate)
                }

                // TODO: 백엔드에서 전화번호를 받으면 표시
                // if let phone = user.phone {
                //     self?.phoneTextField.text = phone
                // }
            })
            .disposed(by: disposeBag)

        // 로딩 상태
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            })
            .disposed(by: disposeBag)

        // 저장 버튼 활성화
        output.isSaveEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.saveButton.isEnabled = isEnabled
                self?.saveButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)

        // 프로필 업데이트 성공
        viewModel.profileUpdated
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showSuccessAndDismiss()
            })
            .disposed(by: disposeBag)

        // 에러 처리
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showError(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        // 이미지 편집 버튼
        editImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showImagePicker()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions

    private func showImagePicker() {
        // TODO: 이미지 선택 기능 구현
        debugLog("Image picker tapped")
    }

    private func showSuccessAndDismiss() {
        let alert = UIAlertController(
            title: "저장 완료",
            message: "프로필이 성공적으로 업데이트되었습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate (전화번호 자동 포맷팅)

extension ProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // phoneTextField에만 적용
        guard textField == phoneTextField else { return true }

        // 숫자만 허용
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) && !string.isEmpty {
            return false
        }

        // 현재 텍스트 가져오기
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // 숫자만 추출
        let digits = updatedText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        // 최대 11자리 (010-0000-0000)
        if digits.count > 11 {
            return false
        }

        // 포맷 적용
        var formattedText = ""
        for (index, character) in digits.enumerated() {
            if index == 3 || index == 7 {
                formattedText += "-"
            }
            formattedText += String(character)
        }

        textField.text = formattedText
        return false
    }
}
