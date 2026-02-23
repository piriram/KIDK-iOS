import UIKit
import SnapKit

final class KIDKNavigationHeaderView: UIView {

    struct ButtonConfig {
        enum ImageSource {
            case systemName(String)
            case image(UIImage)
        }

        let imageSource: ImageSource
        let accessibilityLabel: String?
        let action: (() -> Void)?

        init(systemImageName: String, accessibilityLabel: String? = nil, action: (() -> Void)? = nil) {
            self.imageSource = .systemName(systemImageName)
            self.accessibilityLabel = accessibilityLabel
            self.action = action
        }

        init(image: UIImage, accessibilityLabel: String? = nil, action: (() -> Void)? = nil) {
            self.imageSource = .image(image)
            self.accessibilityLabel = accessibilityLabel
            self.action = action
        }
    }

    static let height: CGFloat = 56

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkTitle
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        return label
    }()

    private let leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .kidkTextWhite
        button.contentHorizontalAlignment = .leading
        button.isHidden = true
        return button
    }()

    private let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .kidkTextWhite
        button.contentHorizontalAlignment = .trailing
        button.isHidden = true
        return button
    }()

    private var leftButtonAction: (() -> Void)?
    private var rightButtonAction: (() -> Void)?

    init(title: String, leftButton: ButtonConfig? = nil, rightButton: ButtonConfig? = nil) {
        super.init(frame: .zero)
        setupUI()
        setTitle(title)
        configureLeftButton(leftButton)
        configureRightButton(rightButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    private func setupUI() {
        backgroundColor = .kidkDarkBackground

        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(titleLabel)

        leftButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        rightButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.lg)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(rightButton.snp.leading).offset(-Spacing.sm)
        }

        leftButton.addTarget(self, action: #selector(handleLeftButtonTap), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(handleRightButtonTap), for: .touchUpInside)
    }

    private func configureLeftButton(_ config: ButtonConfig?) {
        guard let config else {
            leftButton.isHidden = true
            leftButtonAction = nil
            return
        }

        leftButton.isHidden = false
        leftButtonAction = config.action
        leftButton.accessibilityLabel = config.accessibilityLabel
        leftButton.isEnabled = config.action != nil

        switch config.imageSource {
        case .systemName(let imageName):
            leftButton.setImage(UIImage(systemName: imageName), for: .normal)
        case .image(let image):
            leftButton.setImage(image, for: .normal)
        }
    }

    private func configureRightButton(_ config: ButtonConfig?) {
        guard let config else {
            rightButton.isHidden = true
            rightButtonAction = nil
            return
        }

        rightButton.isHidden = false
        rightButtonAction = config.action
        rightButton.accessibilityLabel = config.accessibilityLabel
        rightButton.isEnabled = config.action != nil

        switch config.imageSource {
        case .systemName(let imageName):
            rightButton.setImage(UIImage(systemName: imageName), for: .normal)
        case .image(let image):
            rightButton.setImage(image, for: .normal)
        }
    }

    @objc private func handleLeftButtonTap() {
        leftButtonAction?()
    }

    @objc private func handleRightButtonTap() {
        rightButtonAction?()
    }
}
