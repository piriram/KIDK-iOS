//
//  MissionVerificationViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MissionVerificationViewController: BaseViewController {

    private let viewModel: MissionVerificationViewModel

    private let photoSelectedRelay = BehaviorRelay<UIImage?>(value: nil)
    private let textInputRelay = BehaviorRelay<String>(value: "")
    private let memoRelay = BehaviorRelay<String?>(value: nil)

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentView = UIView()

    private let missionInfoCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "인증 방법 선택"
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let typeSelector = VerificationTypeSelector()

    private let photoContainerView = UIView()
    private let textContainerView = UIView()

    private lazy var photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📷 사진 선택", for: .normal)
        button.titleLabel?.font = .kidkFont(.s16, .medium)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = CornerRadius.large
        return button
    }()

    private let photoPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = CornerRadius.medium
        imageView.isHidden = true
        return imageView
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .kidkFont(.s16, .regular)
        textView.textColor = .kidkTextWhite
        textView.backgroundColor = UIColor(hex: "#2C2C2E")
        textView.layer.cornerRadius = CornerRadius.medium
        textView.textContainerInset = UIEdgeInsets(top: Spacing.md, left: Spacing.md, bottom: Spacing.md, right: Spacing.md)
        return textView
    }()

    private let charCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/500"
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let memoTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "추가 메모 (선택)"
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = CornerRadius.medium
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Spacing.md, height: 0))
        textField.leftViewMode = .always
        textField.attributedPlaceholder = NSAttributedString(
            string: "예: 오늘 용돈 기입장을 썼어요",
            attributes: [.foregroundColor: UIColor.kidkGray]
        )
        return textField
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("인증 제출", for: .normal)
        button.titleLabel?.font = .kidkFont(.s18, .bold)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = CornerRadius.large
        button.isEnabled = false
        return button
    }()

    init(viewModel: MissionVerificationViewModel) {
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
        title = "미션 인증하기"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(missionInfoCard)
        missionInfoCard.addSubview(missionTitleLabel)
        missionInfoCard.addSubview(progressLabel)

        contentView.addSubview(sectionTitleLabel)
        contentView.addSubview(typeSelector)

        contentView.addSubview(photoContainerView)
        photoContainerView.addSubview(photoButton)
        photoContainerView.addSubview(photoPreviewImageView)

        contentView.addSubview(textContainerView)
        textContainerView.addSubview(textView)
        textContainerView.addSubview(charCountLabel)

        contentView.addSubview(memoTextField)
        contentView.addSubview(submitButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        missionInfoCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(80)
        }

        missionTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(missionTitleLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        sectionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(missionInfoCard.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        typeSelector.snp.makeConstraints { make in
            make.top.equalTo(sectionTitleLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(120)
        }

        photoContainerView.snp.makeConstraints { make in
            make.top.equalTo(typeSelector.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(200)
        }

        photoButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(120)
        }

        photoPreviewImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        textContainerView.snp.makeConstraints { make in
            make.top.equalTo(typeSelector.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(200)
        }

        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        charCountLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(textView).inset(Spacing.sm)
        }

        memoTextField.snp.makeConstraints { make in
            make.top.equalTo(photoContainerView.snp.bottom).offset(Spacing.md)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(48)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextField.snp.bottom).offset(Spacing.xl)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-Spacing.xl)
        }
    }

    private func bind() {
        let input = MissionVerificationViewModel.Input(
            verificationType: typeSelector.selectedType,
            photoSelected: photoSelectedRelay.asObservable(),
            textInput: textView.rx.text.orEmpty.asObservable(),
            memo: memoTextField.rx.text.asObservable(),
            submitTapped: submitButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.missionInfo
            .drive(onNext: { [weak self] title, progress in
                self?.missionTitleLabel.text = title
                self?.progressLabel.text = "진행률: \(progress)%"
            })
            .disposed(by: disposeBag)

        output.isPhotoMode
            .drive(onNext: { [weak self] isPhoto in
                self?.photoContainerView.isHidden = !isPhoto
                self?.textContainerView.isHidden = isPhoto
            })
            .disposed(by: disposeBag)

        output.characterCount
            .drive(charCountLabel.rx.text)
            .disposed(by: disposeBag)

        output.isSubmitEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.submitButton.isEnabled = isEnabled
                self?.submitButton.alpha = isEnabled ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)

        output.validationError
            .compactMap { $0 }
            .drive(onNext: { [weak self] error in
                self?.showAlert(title: "오류", message: error)
            })
            .disposed(by: disposeBag)

        output.verificationSubmitted
            .drive(onNext: { [weak self] verification in
                self?.showSuccess()
            })
            .disposed(by: disposeBag)

        photoButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showPhotoActionSheet()
            })
            .disposed(by: disposeBag)

        photoSelectedRelay
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] image in
                self?.photoPreviewImageView.image = image
                self?.photoPreviewImageView.isHidden = false
                self?.photoButton.isHidden = true
            })
            .disposed(by: disposeBag)

        textView.rx.text
            .orEmpty
            .bind(to: textInputRelay)
            .disposed(by: disposeBag)

        memoTextField.rx.text
            .bind(to: memoRelay)
            .disposed(by: disposeBag)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func showPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "사진 선택", message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "사진 촬영", style: .default) { [weak self] _ in
            self?.openCamera()
        })

        actionSheet.addAction(UIAlertAction(title: "앨범에서 선택", style: .default) { [weak self] _ in
            self?.openPhotoLibrary()
        })

        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(actionSheet, animated: true)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "카메라를 사용할 수 없어요", message: "")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func showSuccess() {
        let alert = UIAlertController(
            title: "완료",
            message: "부모님께 인증을 보냈어요!\n승인되면 알려드릴게요.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })

        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MissionVerificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photoSelectedRelay.accept(image)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
