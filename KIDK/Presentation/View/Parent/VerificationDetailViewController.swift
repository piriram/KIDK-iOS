//
//  VerificationDetailViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class VerificationDetailViewController: BaseViewController {

    private let viewModel: VerificationDetailViewModel

    private let rejectTappedRelay = PublishRelay<String>()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let headerCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s20, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 0
        return label
    }()

    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let submittedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let contentSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "인증 내용"
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = CornerRadius.medium
        imageView.backgroundColor = .kidkDarkBackground
        imageView.isHidden = true
        return imageView
    }()

    private let textContentLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .regular)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let memoCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.medium
        view.isHidden = true
        return view
    }()

    private let memoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "추가 메모"
        label.font = .kidkFont(.s14, .bold)
        label.textColor = .kidkGray
        return label
    }()

    private let memoLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .regular)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 0
        return label
    }()

    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.sm
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var rejectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("거절", for: .normal)
        button.titleLabel?.font = .kidkFont(.s18, .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = CornerRadius.large
        return button
    }()

    private lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("승인", for: .normal)
        button.titleLabel?.font = .kidkFont(.s18, .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .kidkGreen
        button.layer.cornerRadius = CornerRadius.large
        return button
    }()

    init(viewModel: VerificationDetailViewModel) {
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
        title = "인증 확인"
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerCard)
        headerCard.addSubview(missionTitleLabel)
        headerCard.addSubview(typeLabel)
        headerCard.addSubview(submittedDateLabel)

        contentView.addSubview(contentSectionLabel)
        contentView.addSubview(photoImageView)
        contentView.addSubview(textContentLabel)

        contentView.addSubview(memoCard)
        memoCard.addSubview(memoTitleLabel)
        memoCard.addSubview(memoLabel)

        contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(rejectButton)
        buttonStackView.addArrangedSubview(approveButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        headerCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        missionTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(missionTitleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.equalToSuperview().offset(Spacing.md)
        }

        submittedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        contentSectionLabel.snp.makeConstraints { make in
            make.top.equalTo(headerCard.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(contentSectionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(300)
        }

        textContentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentSectionLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        memoCard.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        memoTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(memoTitleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.bottom.equalToSuperview().inset(Spacing.md)
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(memoCard.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }
    }

    private func bind() {
        let input = VerificationDetailViewModel.Input(
            approveTapped: approveButton.rx.tap.asObservable(),
            rejectTapped: rejectTappedRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.verification
            .drive(onNext: { [weak self] verification in
                self?.typeLabel.text = "\(verification.type.icon) \(verification.type.displayName)"
                self?.submittedDateLabel.text = "제출: \(verification.formattedSubmittedDate)"

                if let memo = verification.memo, !memo.isEmpty {
                    self?.memoCard.isHidden = false
                    self?.memoLabel.text = memo
                } else {
                    self?.memoCard.isHidden = true
                }
            })
            .disposed(by: disposeBag)

        output.missionTitle
            .drive(missionTitleLabel.rx.text)
            .disposed(by: disposeBag)

        output.photoImage
            .drive(onNext: { [weak self] image in
                if let image = image {
                    self?.photoImageView.image = image
                    self?.photoImageView.isHidden = false
                    self?.textContentLabel.isHidden = true
                }
            })
            .disposed(by: disposeBag)

        output.textContent
            .drive(onNext: { [weak self] text in
                if let text = text, !text.isEmpty {
                    self?.textContentLabel.text = text
                    self?.textContentLabel.isHidden = false
                    self?.photoImageView.isHidden = true
                }
            })
            .disposed(by: disposeBag)

        output.approvalSuccess
            .drive(onNext: { [weak self] in
                self?.showSuccessAndDismiss(message: "인증을 승인했어요!")
            })
            .disposed(by: disposeBag)

        output.rejectionSuccess
            .drive(onNext: { [weak self] in
                self?.showSuccessAndDismiss(message: "인증을 거절했어요")
            })
            .disposed(by: disposeBag)

        output.error
            .compactMap { $0 }
            .drive(onNext: { [weak self] error in
                self?.showAlert(title: "오류", message: error)
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.approveButton.isEnabled = !isLoading
                self?.rejectButton.isEnabled = !isLoading
                self?.approveButton.alpha = isLoading ? 0.5 : 1.0
                self?.rejectButton.alpha = isLoading ? 0.5 : 1.0
            })
            .disposed(by: disposeBag)

        rejectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showRejectReasonAlert()
            })
            .disposed(by: disposeBag)
    }

    private func showRejectReasonAlert() {
        let alert = UIAlertController(
            title: "거절 사유",
            message: "거절 사유를 선택해주세요",
            preferredStyle: .actionSheet
        )

        let reasons = [
            "미션 내용과 맞지 않아요",
            "인증 내용이 불충분해요",
            "다시 한 번 확인이 필요해요",
            "기타"
        ]

        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason, style: .default) { [weak self] _ in
                if reason == "기타" {
                    self?.showCustomReasonAlert()
                } else {
                    self?.rejectTappedRelay.accept(reason)
                }
            })
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alert, animated: true)
    }

    private func showCustomReasonAlert() {
        let alert = UIAlertController(
            title: "거절 사유 입력",
            message: "거절 사유를 입력해주세요",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "거절 사유"
        }

        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self, weak alert] _ in
            guard let textField = alert?.textFields?.first,
                  let reason = textField.text,
                  !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                self?.showAlert(title: "오류", message: "거절 사유를 입력해주세요")
                return
            }
            self?.rejectTappedRelay.accept(reason)
        })

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alert, animated: true)
    }

    private func showSuccessAndDismiss(message: String) {
        let alert = UIAlertController(
            title: "완료",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }
}
