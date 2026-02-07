//
//  SettingsViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

//
//  SettingsViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SettingsViewController: BaseViewController {
    
    private let authRepository: AuthRepositoryProtocol
    weak var coordinator: SettingsCoordinator?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "설정",
            size: .s28,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()
    
    private lazy var logoutButton = KIDKButton(
        title: "로그아웃",
        backgroundColor: .kidkPink,
        titleColor: .kidkTextWhite,
        font: .kidkFont(.s16, .bold)
    )
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
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
        view.addSubview(titleLabel)
        view.addSubview(logoutButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(56)
        }
    }
    
    private func bind() {
        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showLogoutConfirmation()
            })
            .disposed(by: disposeBag)
    }
    
    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        showLoading()
        
        authRepository.clearSession()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.hideLoading()
                self?.debugSuccess("Logout successful")
                self?.coordinator?.logout()
            }, onError: { [weak self] error in
                self?.hideLoading()
                self?.debugError("Logout failed", error: error)
                self?.showError(message: "로그아웃에 실패했습니다.")
            })
            .disposed(by: disposeBag)
    }
}
