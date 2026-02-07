//
//  SignupViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignupViewController: BaseViewController {
    
    private let viewModel: SignupViewModel
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "회원가입",
            size: .s28,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "KIDK와 함께 시작해보세요",
            size: .s16,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        return label
    }()
    
    private let userTypeLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "사용자 유형",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()
    
    private let userTypeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.sm
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var childButton = KIDKButton(
        title: "어린이",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )
    
    private lazy var parentButton = KIDKButton(
        title: "부모님",
        backgroundColor: .cardBackground,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )
    
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
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "이름을 입력하세요",
            attributes: [.foregroundColor: UIColor.kidkGray]
        )
        
        return textField
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "이메일",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력하세요"
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.backgroundColor = .cardBackground
        textField.layer.cornerRadius = CornerRadius.medium
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "이메일을 입력하세요",
            attributes: [.foregroundColor: UIColor.kidkGray]
        )
        
        return textField
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "비밀번호",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력하세요"
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.backgroundColor = .cardBackground
        textField.layer.cornerRadius = CornerRadius.medium
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "비밀번호를 입력하세요",
            attributes: [.foregroundColor: UIColor.kidkGray]
        )
        
        return textField
    }()
    
    private let passwordConfirmLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "비밀번호 확인",
            size: .s14,
            weight: .medium,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()
    
    private let passwordConfirmTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 다시 입력하세요"
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.backgroundColor = .cardBackground
        textField.layer.cornerRadius = CornerRadius.medium
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "비밀번호를 다시 입력하세요",
            attributes: [.foregroundColor: UIColor.kidkGray]
        )
        
        return textField
    }()
    
    private lazy var signupButton = KIDKButton(
        title: "회원가입",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )
    
    init(viewModel: SignupViewModel) {
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(userTypeLabel)
        contentView.addSubview(userTypeStackView)
        userTypeStackView.addArrangedSubview(childButton)
        userTypeStackView.addArrangedSubview(parentButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(passwordConfirmLabel)
        contentView.addSubview(passwordConfirmTextField)
        contentView.addSubview(signupButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        userTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        userTypeStackView.snp.makeConstraints { make in
            make.top.equalTo(userTypeLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(userTypeStackView.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }
        
        passwordConfirmLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        passwordConfirmTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }
        
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(passwordConfirmTextField.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-Spacing.lg)
        }
    }
    
    private func bind() {
        let userTypeSelected = Observable.merge(
            childButton.rx.tap.map { UserType.child },
            parentButton.rx.tap.map { UserType.parent }
        )
        
        let input = SignupViewModel.Input(
            nameText: nameTextField.rx.text.orEmpty.asObservable(),
            emailText: emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
            passwordConfirmText: passwordConfirmTextField.rx.text.orEmpty.asObservable(),
            userTypeSelected: userTypeSelected,
            signupButtonTapped: signupButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.selectedUserType
            .drive(onNext: { [weak self] userType in
                self?.updateUserTypeButtons(selected: userType)
            })
            .disposed(by: disposeBag)
        
        output.isSignupEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.signupButton.isEnabled = isEnabled
                self?.signupButton.alpha = isEnabled ? 1.0 : 0.5
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
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showError(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUserTypeButtons(selected: UserType) {
        if selected == .child {
            childButton.backgroundColor = .kidkPink
            parentButton.backgroundColor = .cardBackground
        } else {
            childButton.backgroundColor = .cardBackground
            parentButton.backgroundColor = .kidkPink
        }
    }
}
