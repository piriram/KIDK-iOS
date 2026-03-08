//
//  ReceiptScanViewController.swift
//  KIDK
//
//  영수증 스캔 화면
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Vision
import VisionKit
import CoreImage

final class ReceiptScanViewController: BaseViewController {

    // MARK: - Properties
    private let transactionRepository: TransactionRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol
    private var selectedAccount: Account?
    private var scannedText: String = ""
    private var extractedAmount: Int?
    private var extractedDescription: String?
    private var autoFillConfirmed = false

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()

    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "영수증 스캔"
        label.font = .kidkFont(.s24, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "카메라로 영수증을 스캔하거나\n앨범에서 영수증 사진을 선택하세요"
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    // 이미지 프리뷰
    private let imagePreview: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor(hex: "#2C2C2E")
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    // 스캔 버튼들
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.setTitle("📷 카메라로 스캔", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.titleLabel?.font = .kidkFont(.s16, .medium)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = 12
        return button
    }()

    private let photoButton: UIButton = {
        let button = UIButton()
        button.setTitle("🖼 앨범에서 선택", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.titleLabel?.font = .kidkFont(.s16, .medium)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = 12
        return button
    }()

    // 계좌 선택
    private let accountLabel: UILabel = {
        let label = UILabel()
        label.text = "출금 계좌"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let accountButton: UIButton = {
        let button = UIButton()
        button.setTitle("계좌 선택", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.titleLabel?.font = .kidkFont(.s16, .medium)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = 12
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.isHidden = true
        return button
    }()

    // 금액 정보
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "금액"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        label.isHidden = true
        return label
    }()

    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.font = .kidkFont(.s24, .bold)
        textField.textColor = .kidkPink
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        textField.placeholder = "0"
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = 12
        textField.isHidden = true

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always

        return textField
    }()

    private let wonLabel: UILabel = {
        let label = UILabel()
        label.text = "원"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        label.isHidden = true
        return label
    }()

    // 설명
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "내용"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        label.isHidden = true
        return label
    }()

    private let descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.font = .kidkFont(.s16, .regular)
        textField.textColor = .kidkTextWhite
        textField.placeholder = "거래 내용을 입력하세요"
        textField.backgroundColor = UIColor(hex: "#2C2C2E")
        textField.layer.cornerRadius = 12
        textField.isHidden = true

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always

        return textField
    }()

    private let autoFillStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .medium)
        label.textColor = .kidkGray
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()

    private let confirmAutoFillButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OCR 입력 확인 완료", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.titleLabel?.font = .kidkFont(.s14, .bold)
        button.backgroundColor = UIColor(hex: "#3A3A3C")
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()

    // 카테고리 선택
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = .kidkFont(.s16, .medium)
        label.textColor = .kidkGray
        label.isHidden = true
        return label
    }()

    private let categoryScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isHidden = true
        return scrollView
    }()

    private let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    private var selectedCategory: TransactionCategory?

    // 저장 버튼
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("거래 내역 저장", for: .normal)
        button.setTitleColor(.kidkTextWhite, for: .normal)
        button.titleLabel?.font = .kidkFont(.s18, .bold)
        button.backgroundColor = .kidkPink
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.alpha = 0.5
        button.isHidden = true
        return button
    }()

    // MARK: - Initialization
    init(
        transactionRepository: TransactionRepositoryProtocol = TransactionRepository.shared,
        accountRepository: AccountRepositoryProtocol = AccountRepository.shared
    ) {
        self.transactionRepository = transactionRepository
        self.accountRepository = accountRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
#if DEBUG
        ReceiptOCRParser.runSmokeTests()
#endif
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        title = "영수증 스캔"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, instructionLabel, imagePreview, cameraButton, photoButton,
         accountLabel, accountButton, amountLabel, amountTextField, wonLabel,
         descriptionLabel, descriptionTextField, autoFillStatusLabel, confirmAutoFillButton,
         categoryLabel, categoryScrollView, saveButton].forEach {
            contentView.addSubview($0)
        }
        categoryScrollView.addSubview(categoryStackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        imagePreview.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }

        cameraButton.snp.makeConstraints { make in
            make.top.equalTo(imagePreview.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        photoButton.snp.makeConstraints { make in
            make.top.equalTo(cameraButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        accountLabel.snp.makeConstraints { make in
            make.top.equalTo(photoButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        accountButton.snp.makeConstraints { make in
            make.top.equalTo(accountLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(accountButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(wonLabel.snp.leading).offset(-8)
            make.height.equalTo(60)
        }

        wonLabel.snp.makeConstraints { make in
            make.centerY.equalTo(amountTextField)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(30)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        autoFillStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        confirmAutoFillButton.snp.makeConstraints { make in
            make.top.equalTo(autoFillStatusLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(confirmAutoFillButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        categoryScrollView.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }

        categoryStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalTo(80)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupActions() {
        cameraButton.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        photoButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        accountButton.addTarget(self, action: #selector(selectAccount), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTransaction), for: .touchUpInside)
        confirmAutoFillButton.addTarget(self, action: #selector(confirmAutoFill), for: .touchUpInside)

        amountTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        setupCategoryButtons()
    }

    private func setupCategoryButtons() {
        let categories = TransactionCategory.allCases

        for category in categories {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor(hex: "#2C2C2E")
            button.layer.cornerRadius = CornerRadius.medium
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.clear.cgColor

            // 버튼 내용 구성
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 4
            stackView.alignment = .center
            stackView.isUserInteractionEnabled = false

            let emojiLabel = UILabel()
            emojiLabel.text = category.emoji
            emojiLabel.font = .systemFont(ofSize: 28)

            let nameLabel = UILabel()
            nameLabel.text = category.rawValue
            nameLabel.font = .kidkFont(.s12, .medium)
            nameLabel.textColor = .kidkTextWhite

            stackView.addArrangedSubview(emojiLabel)
            stackView.addArrangedSubview(nameLabel)

            button.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }

            button.tag = categories.firstIndex(of: category) ?? 0
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)

            button.snp.makeConstraints { make in
                make.width.equalTo(70)
            }

            categoryStackView.addArrangedSubview(button)
        }
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        let categories = TransactionCategory.allCases
        selectedCategory = categories[sender.tag]

        // 모든 버튼 초기화
        for case let button as UIButton in categoryStackView.arrangedSubviews {
            button.layer.borderColor = UIColor.clear.cgColor
        }

        // 선택된 버튼 강조
        sender.layer.borderColor = UIColor.kidkPink.cgColor

        validateForm()
    }

    // MARK: - Actions
    @objc private func openCamera() {
        if VNDocumentCameraViewController.isSupported {
            let documentCamera = VNDocumentCameraViewController()
            documentCamera.delegate = self
            present(documentCamera, animated: true)
        } else {
            // Document camera not supported, use regular camera
            openImagePicker(sourceType: .camera)
        }
    }

    @objc private func openPhotoLibrary() {
        openImagePicker(sourceType: .photoLibrary)
    }

    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            showAlert(title: "오류", message: "카메라를 사용할 수 없습니다.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func selectAccount() {
        accountRepository.getAllAccounts()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] accounts in
                self?.showAccountPicker(accounts: accounts)
            }, onFailure: { [weak self] error in
                self?.showAlert(title: "오류", message: "계좌 목록을 불러올 수 없습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func showAccountPicker(accounts: [Account]) {
        let alert = UIAlertController(title: "계좌 선택", message: nil, preferredStyle: .actionSheet)

        for account in accounts {
            let action = UIAlertAction(title: "\(account.name) (\(account.balance.formattedWithComma)원)", style: .default) { [weak self] _ in
                self?.selectedAccount = account
                self?.accountButton.setTitle("\(account.name) (\(account.balance.formattedWithComma)원)", for: .normal)
                self?.validateForm()
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func textFieldDidChange() {
        autoFillConfirmed = false
        updateAutoFillStatusLabel()
        validateForm()
    }

    @objc private func confirmAutoFill() {
        autoFillConfirmed = true
        updateAutoFillStatusLabel()
        validateForm()
    }

    @objc private func validateForm() {
        let hasAccount = selectedAccount != nil
        let hasValidAmount = {
            guard let text = amountTextField.text,
                  let amount = Int(text) else {
                return false
            }
            return amount > 0
        }()
        let hasDescription = !(descriptionTextField.text?.isEmpty ?? true)
        let hasCategory = selectedCategory != nil

        let isValid = hasAccount && hasValidAmount && hasDescription && hasCategory && autoFillConfirmed

        saveButton.isEnabled = isValid
        saveButton.alpha = isValid ? 1.0 : 0.5
    }

    private func updateAutoFillStatusLabel() {
        autoFillStatusLabel.isHidden = false
        confirmAutoFillButton.isHidden = false

        if autoFillConfirmed {
            autoFillStatusLabel.textColor = .systemGreen
            autoFillStatusLabel.text = "확인 완료: OCR 자동 입력값을 검토하고 확정했습니다."
            confirmAutoFillButton.backgroundColor = .systemGreen
            confirmAutoFillButton.setTitle("확인 완료됨", for: .normal)
        } else {
            autoFillStatusLabel.textColor = .kidkGray
            autoFillStatusLabel.text = "안내: 자동 입력값을 확인 후 'OCR 입력 확인 완료'를 눌러야 저장할 수 있어요."
            confirmAutoFillButton.backgroundColor = UIColor(hex: "#3A3A3C")
            confirmAutoFillButton.setTitle("OCR 입력 확인 완료", for: .normal)
        }
    }

    @objc private func saveTransaction() {
        guard autoFillConfirmed else {
            showAlert(title: "확인 필요", message: "OCR 자동 입력값 확인 완료 후 저장할 수 있습니다.")
            return
        }

        guard let account = selectedAccount,
              let amountText = amountTextField.text,
              let amount = Int(amountText),
              let description = descriptionTextField.text,
              let category = selectedCategory else {
            showAlert(title: "정보 확인", message: "모든 항목을 입력해주세요.")
            return
        }

        // 잔액 확인
        if account.balance < amount {
            showAlert(title: "잔액 부족", message: "계좌의 잔액이 부족합니다.")
            return
        }

        showLoading()

        transactionRepository.createTransaction(
            accountId: account.id,
            type: .withdrawal,
            amount: amount,
            category: category,
            description: description,
            memo: "영수증 스캔"
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onSuccess: { [weak self] _ in
            self?.hideLoading()
            self?.showSuccessAndDismiss(amount: amount)
        }, onFailure: { [weak self] error in
            self?.hideLoading()
            self?.showAlert(title: "저장 실패", message: "거래 내역 저장 중 오류가 발생했습니다.\n\(error.localizedDescription)")
        })
        .disposed(by: disposeBag)
    }

    private func showSuccessAndDismiss(amount: Int) {
        let alert = UIAlertController(
            title: "저장 완료",
            message: "\(amount.formattedWithComma)원 거래 내역이 저장되었습니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }

    // MARK: - Vision Processing
    private enum ScanSource {
        case documentCamera
        case photoLibrary
    }

    private func processImage(_ image: UIImage, source: ScanSource) {
        showLoading()

        let preferredImage = source == .documentCamera ? enhanceForDocumentOCR(image) : image
        let fallbackImage = source == .documentCamera ? image : nil
        let parser = ReceiptOCRParser()

        recognizeText(from: preferredImage) { [weak self] observations in
            guard let self = self else { return }

            if observations.isEmpty, let fallbackImage {
                self.recognizeText(from: fallbackImage) { [weak self] fallbackObservations in
                    self?.handleOCRResult(observations: fallbackObservations, parser: parser)
                }
            } else {
                self.handleOCRResult(observations: observations, parser: parser)
            }
        }
    }

    private func handleOCRResult(observations: [VNRecognizedTextObservation], parser: ReceiptOCRParser) {
        DispatchQueue.main.async {
            self.hideLoading()

            guard !observations.isEmpty else {
                self.showEditableInputsWithFallback(message: "텍스트를 인식하지 못했어요. 직접 입력해 주세요.")
                return
            }

            let result = parser.parse(observations: observations)
            self.scannedText = result.recognizedText
            self.extractedAmount = result.amount
            self.extractedDescription = result.merchantName
            self.showExtractedData(result: result)
        }
    }

    private func recognizeText(from image: UIImage, completion: @escaping ([VNRecognizedTextObservation]) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async { [weak self] in
                self?.hideLoading()
                self?.showAlert(title: "오류", message: "이미지를 처리할 수 없습니다.")
            }
            completion([])
            return
        }

        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            completion(observations)
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.012

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion([])
            }
        }
    }

    private func enhanceForDocumentOCR(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        let exposureAdjusted = ciImage.applyingFilter("CIExposureAdjust", parameters: [kCIInputEVKey: 0.5])
        let contrastAdjusted = exposureAdjusted.applyingFilter("CIColorControls", parameters: [kCIInputContrastKey: 1.15])

        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(contrastAdjusted, from: contrastAdjusted.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    private func showEditableInputsWithFallback(message: String) {
        extractedAmount = nil
        extractedDescription = nil
        showExtractedData(result: nil)
        autoFillStatusLabel.textColor = .systemOrange
        autoFillStatusLabel.text = message
        autoFillConfirmed = false
        validateForm()
    }

    private func showExtractedData(result: ReceiptOCRResult?) {
        // UI 요소 표시
        accountLabel.isHidden = false
        accountButton.isHidden = false
        amountLabel.isHidden = false
        amountTextField.isHidden = false
        wonLabel.isHidden = false
        descriptionLabel.isHidden = false
        descriptionTextField.isHidden = false
        autoFillStatusLabel.isHidden = false
        confirmAutoFillButton.isHidden = false
        categoryLabel.isHidden = false
        categoryScrollView.isHidden = false
        saveButton.isHidden = false

        // 추출된 데이터 채우기
        if let amount = extractedAmount {
            amountTextField.text = "\(amount)"
        } else {
            amountTextField.text = nil
        }

        if let description = extractedDescription {
            descriptionTextField.text = description
        } else {
            descriptionTextField.text = nil
        }

        autoFillConfirmed = false
        updateAutoFillStatusLabel()

        if let result {
            if result.amount == nil || result.merchantName == nil {
                autoFillStatusLabel.textColor = .systemOrange
                autoFillStatusLabel.text = "일부 항목 인식이 불완전해요. 직접 수정 후 확인 버튼을 눌러주세요."
            }
        }

        validateForm()

        // 스크롤
        scrollView.setContentOffset(.zero, animated: true)
    }
}

private struct ReceiptOCRResult {
    let amount: Int?
    let merchantName: String?
    let recognizedText: String
}

private struct ReceiptOCRParser {
    private let amountKeywords = ["합계", "총액", "결제", "total", "amount", "sum"]

    func parse(observations: [VNRecognizedTextObservation]) -> ReceiptOCRResult {
        let lines = observations
            .compactMap { observation -> (text: String, box: CGRect)? in
                guard let text = observation.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines),
                      !text.isEmpty else { return nil }
                return (text: text, box: observation.boundingBox)
            }
            .sorted { lhs, rhs in
                if abs(lhs.box.midY - rhs.box.midY) > 0.02 {
                    return lhs.box.midY > rhs.box.midY
                }
                return lhs.box.minX < rhs.box.minX
            }

        let recognizedText = lines.map(\.text).joined(separator: "\n")
        let amount = extractAmount(from: lines)
        let merchantName = extractMerchantName(from: lines)

        return ReceiptOCRResult(amount: amount, merchantName: merchantName, recognizedText: recognizedText)
    }

    private func extractAmount(from lines: [(text: String, box: CGRect)]) -> Int? {
        var allCandidates: [Int] = []
        var prioritized: [(amount: Int, score: Int)] = []

        for (index, line) in lines.enumerated() {
            let amounts = amountsInLine(line.text)
            allCandidates.append(contentsOf: amounts)

            let lower = line.text.lowercased()
            if amountKeywords.contains(where: { lower.contains($0) }) {
                let nearby = (index - 3...index + 3).compactMap { i -> String? in
                    guard lines.indices.contains(i) else { return nil }
                    return lines[i].text
                }

                for target in nearby {
                    for amount in amountsInLine(target) {
                        var score = amount
                        if target.contains(",") { score += 5_000_000 }
                        if amount % 10 == 0 { score += 1_000 }
                        prioritized.append((amount, score))
                    }
                }
            }
        }

        let keywordAmount = prioritized.sorted { $0.score > $1.score }.first?.amount
        if let keywordAmount {
            if keywordAmount < 10_000, allCandidates.contains(keywordAmount * 10) {
                return keywordAmount * 10
            }
            return keywordAmount
        }

        return allCandidates.max()
    }

    private func amountsInLine(_ line: String) -> [Int] {
        let pattern = "[0-9OolI]{1,3}(?:,[0-9OolI]{3})+|[0-9OolI]{3,}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsRange = NSRange(line.startIndex..., in: line)

        return regex.matches(in: line, range: nsRange)
            .compactMap { match -> Int? in
                guard let range = Range(match.range, in: line) else { return nil }
                return normalizeAmountToken(String(line[range]))
            }
            .filter { 100...5_000_000 ~= $0 }
    }

    private func normalizeAmountToken(_ token: String) -> Int? {
        let normalized = token
            .replacingOccurrences(of: "O", with: "0")
            .replacingOccurrences(of: "o", with: "0")
            .replacingOccurrences(of: "I", with: "1")
            .replacingOccurrences(of: "l", with: "1")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")

        return Int(normalized)
    }

    private func extractMerchantName(from lines: [(text: String, box: CGRect)]) -> String? {
        let topLines = lines.filter { $0.box.midY > 0.6 }

        let filteredCandidates = topLines
            .map(\.text)
            .filter { text in
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count < 2 || trimmed.count > 32 { return false }
                if trimmed.range(of: #"\d{2,3}-\d{3,4}-\d{4}"#, options: .regularExpression) != nil { return false }
                if trimmed.contains("도로") || trimmed.contains("길") || trimmed.contains("번지") || trimmed.contains("층") { return false }
                let digitCount = trimmed.filter { $0.isNumber }.count
                return digitCount < max(4, trimmed.count / 2)
            }

        return filteredCandidates.max(by: { $0.count < $1.count })
    }
}

#if DEBUG
private extension ReceiptOCRParser {
    static func runSmokeTests() {
        let parser = ReceiptOCRParser()
        let sampleLines: [(text: String, box: CGRect)] = [
            ("키드키드 편의점", CGRect(x: 0.1, y: 0.88, width: 0.5, height: 0.04)),
            ("합계 10,000", CGRect(x: 0.1, y: 0.35, width: 0.5, height: 0.04))
        ]
        let amount = parser.extractAmount(from: sampleLines)
        assert(amount == 10000, "ReceiptOCRParser 금액 파싱 테스트 실패")
        let merchant = parser.extractMerchantName(from: sampleLines)
        assert(merchant == "키드키드 편의점", "ReceiptOCRParser 상호명 파싱 테스트 실패")
    }
}
#endif

// MARK: - VNDocumentCameraViewControllerDelegate
extension ReceiptScanViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)

        guard scan.pageCount > 0 else { return }

        let image = scan.imageOfPage(at: 0)
        imagePreview.image = image
        imagePreview.isHidden = false

        processImage(image, source: .documentCamera)
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
        showAlert(title: "스캔 실패", message: error.localizedDescription)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ReceiptScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        imagePreview.image = image
        imagePreview.isHidden = false

        processImage(image, source: .photoLibrary)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
