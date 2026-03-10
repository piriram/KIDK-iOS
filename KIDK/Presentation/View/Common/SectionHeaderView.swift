import UIKit
import SnapKit

final class SectionHeaderView: UIView {

    var onTrailingTap: (() -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s20,
            weight: .bold,
            color: .kidkTextWhite,
            lineHeight: 140
        )
        return label
    }()

    private let trailingButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .kidkGray
        button.setTitleColor(.kidkGray, for: .normal)
        button.titleLabel?.font = UIFont.kidkFont(.s12, .medium)
        button.semanticContentAttribute = .forceLeftToRight
        button.contentHorizontalAlignment = .right
        button.isHidden = true
        return button
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.applyTextStyle(
            text: "",
            size: .s14,
            weight: .regular,
            color: .kidkGray,
            lineHeight: 140
        )
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(trailingButton)
        addSubview(subtitleLabel)

        trailingButton.addTarget(self, action: #selector(didTapTrailing), for: .touchUpInside)
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        trailingButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(Spacing.xs)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleLabel)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    @objc
    private func didTapTrailing() {
        onTrailingTap?()
    }
    
    func configure(title: String, subtitle: String? = nil, trailingText: String? = nil, trailingIconName: String? = nil) {
        titleLabel.text = title

        if let trailingText, !trailingText.isEmpty {
            trailingButton.setTitle(trailingText, for: .normal)
            if let trailingIconName {
                trailingButton.setImage(UIImage(systemName: trailingIconName), for: .normal)
                trailingButton.imageView?.contentMode = .scaleAspectFit
                trailingButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
            } else {
                trailingButton.setImage(nil, for: .normal)
            }
            trailingButton.isHidden = false
        } else {
            trailingButton.isHidden = true
        }

        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }

    func applyStyle(titleColor: UIColor, subtitleColor: UIColor) {
        titleLabel.textColor = titleColor
        subtitleLabel.textColor = subtitleColor
        trailingButton.setTitleColor(subtitleColor, for: .normal)
        trailingButton.tintColor = subtitleColor
    }
}

