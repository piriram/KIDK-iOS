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

final class ReceiptScanViewController: BaseViewController {

    // MARK: - Properties
    private let transactionRepository: TransactionRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol
    private var selectedAccount: Account?
    private var scannedText: String = ""
    private var extractedAmount: Int?
    private var extractedDescription: String?

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
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        title = "영수증 스캔"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, instructionLabel, imagePreview, cameraButton, photoButton,
         accountLabel, accountButton, amountLabel, amountTextField, wonLabel,
         descriptionLabel, descriptionTextField, saveButton].forEach {
            contentView.addSubview($0)
        }

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

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(40)
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

        amountTextField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
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

        let isValid = hasAccount && hasValidAmount && hasDescription

        saveButton.isEnabled = isValid
        saveButton.alpha = isValid ? 1.0 : 0.5
    }

    @objc private func saveTransaction() {
        guard let account = selectedAccount,
              let amountText = amountTextField.text,
              let amount = Int(amountText),
              let description = descriptionTextField.text else {
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
            category: .shopping, // 기본 카테고리
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
    private func processImage(_ image: UIImage) {
        showLoading()

        guard let cgImage = image.cgImage else {
            hideLoading()
            showAlert(title: "오류", message: "이미지를 처리할 수 없습니다.")
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.hideLoading()

                if let error = error {
                    self.showAlert(title: "인식 실패", message: "텍스트 인식 중 오류가 발생했습니다.")
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    self.showAlert(title: "인식 실패", message: "텍스트를 찾을 수 없습니다.")
                    return
                }

                self.extractDataFromObservations(observations)
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.showAlert(title: "인식 실패", message: "이미지 분석 중 오류가 발생했습니다.")
                }
            }
        }
    }

    private func extractDataFromObservations(_ observations: [VNRecognizedTextObservation]) {
        var recognizedText = ""

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            recognizedText += topCandidate.string + "\n"
        }

        scannedText = recognizedText

        // 금액 추출 (숫자,숫자 패턴 또는 큰 숫자)
        extractedAmount = extractAmount(from: recognizedText)

        // 상호명 추출 (첫 번째 줄 또는 가장 긴 줄)
        extractedDescription = extractDescription(from: observations)

        // UI 업데이트
        showExtractedData()
    }

    private func extractAmount(from text: String) -> Int? {
        // "합계", "총액", "결제금액" 등의 키워드 근처 숫자 찾기
        let lines = text.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            let lowercased = line.lowercased()
            if lowercased.contains("합계") || lowercased.contains("총액") ||
               lowercased.contains("결제") || lowercased.contains("total") {
                // 현재 줄과 다음 줄에서 숫자 찾기
                for i in index..<min(index + 3, lines.count) {
                    if let amount = extractNumberFromLine(lines[i]) {
                        return amount
                    }
                }
            }
        }

        // 키워드를 못 찾으면 가장 큰 숫자 반환
        var maxAmount = 0
        for line in lines {
            if let amount = extractNumberFromLine(line), amount > maxAmount {
                maxAmount = amount
            }
        }

        return maxAmount > 0 ? maxAmount : nil
    }

    private func extractNumberFromLine(_ line: String) -> Int? {
        // 숫자와 쉼표만 추출
        let numbers = line.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let commaRemoved = line.replacingOccurrences(of: ",", with: "")

        // 숫자 패턴 찾기
        let pattern = "\\d{1,3}(,\\d{3})*|\\d+"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
           let range = Range(match.range, in: line) {
            let numberString = String(line[range]).replacingOccurrences(of: ",", with: "")
            if let amount = Int(numberString), amount >= 100 { // 최소 100원
                return amount
            }
        }

        return nil
    }

    private func extractDescription(from observations: [VNRecognizedTextObservation]) -> String? {
        // 첫 번째 몇 줄 중 가장 긴 줄을 상호명으로 간주
        var candidates: [String] = []

        for i in 0..<min(5, observations.count) {
            if let text = observations[i].topCandidates(1).first?.string {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count >= 2 && trimmed.count <= 30 {
                    candidates.append(trimmed)
                }
            }
        }

        return candidates.max(by: { $0.count < $1.count })
    }

    private func showExtractedData() {
        // UI 요소 표시
        accountLabel.isHidden = false
        accountButton.isHidden = false
        amountLabel.isHidden = false
        amountTextField.isHidden = false
        wonLabel.isHidden = false
        descriptionLabel.isHidden = false
        descriptionTextField.isHidden = false
        saveButton.isHidden = false

        // 추출된 데이터 채우기
        if let amount = extractedAmount {
            amountTextField.text = "\(amount)"
        }

        if let description = extractedDescription {
            descriptionTextField.text = description
        }

        validateForm()

        // 스크롤
        scrollView.setContentOffset(.zero, animated: true)
    }
}

// MARK: - VNDocumentCameraViewControllerDelegate
extension ReceiptScanViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)

        guard scan.pageCount > 0 else { return }

        let image = scan.imageOfPage(at: 0)
        imagePreview.image = image
        imagePreview.isHidden = false

        processImage(image)
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

        processImage(image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
