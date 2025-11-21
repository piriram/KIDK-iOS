//
//  LoginViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController {
    
    private let viewModel: LoginViewModel
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "로그인",
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
            text: "KIDK에 오신 것을 환영합니다",
            size: .s16,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        return label
    }()

    private let userTypeSegmentedControl: UISegmentedControl = {
        let items = ["아이", "부모"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = .cardBackground
        control.selectedSegmentTintColor = .kidkPink
        control.setTitleTextAttributes([.foregroundColor: UIColor.kidkTextWhite], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return control
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
        textField.text = "judy@love.net"
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
        textField.text = "judylove"
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
        
        return textField
    }()
    
    private let autoLoginContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let autoLoginCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = .kidkPink
        return button
    }()
    
    private let autoLoginLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "자동 로그인",
            size: .s14,
            weight: .regular,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()
    
    private lazy var loginButton = KIDKButton(
        title: "로그인",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )
    
    private lazy var signupButton = KIDKButton(
        title: "회원가입",
        backgroundColor: .cardBackground,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )
    
    init(viewModel: LoginViewModel) {
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
        contentView.addSubview(userTypeSegmentedControl)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(autoLoginContainer)
        autoLoginContainer.addSubview(autoLoginCheckbox)
        autoLoginContainer.addSubview(autoLoginLabel)
        contentView.addSubview(loginButton)
        contentView.addSubview(signupButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }

        userTypeSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(36)
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(userTypeSegmentedControl.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(52)
        }
        
        autoLoginContainer.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Spacing.sm)
            make.leading.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(24)
        }
        
        autoLoginCheckbox.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        autoLoginLabel.snp.makeConstraints { make in
            make.leading.equalTo(autoLoginCheckbox.snp.trailing).offset(Spacing.xxs)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(autoLoginContainer.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(56)
        }
        
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-Spacing.lg)
        }
    }
    
    private func bind() {
        let userTypeSelected = userTypeSegmentedControl.rx.selectedSegmentIndex
            .map { index -> UserType in
                return index == 0 ? .child : .parent
            }
            .asObservable()
            .startWith(.child)

        let input = LoginViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
            autoLoginToggled: autoLoginCheckbox.rx.tap.map { [weak self] in
                self?.autoLoginCheckbox.isSelected.toggle()
                return self?.autoLoginCheckbox.isSelected ?? false
            }.asObservable(),
            userTypeSelected: userTypeSelected,
            loginButtonTapped: loginButton.rx.tap.asObservable(),
            signupButtonTapped: signupButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isLoginEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.loginButton.isEnabled = isEnabled
                self?.loginButton.alpha = isEnabled ? 1.0 : 0.5
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
        
        output.savedEmail
            .drive(onNext: { [weak self] email in
                if !email.isEmpty {
                    self?.emailTextField.text = email
                }
            })
            .disposed(by: disposeBag)
        
        output.isAutoLoginEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.autoLoginCheckbox.isSelected = isEnabled
            })
            .disposed(by: disposeBag)
        
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.showError(message: error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
