import UIKit
import SnapKit

final class QuickActionButton: UIButton {

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 18
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    let actionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    init(action: QuickActionType) {
        super.init(frame: .zero)
        configure(with: action)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#2B2C32")
        layer.cornerRadius = CornerRadius.medium
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        addSubview(actionTitleLabel)

        iconBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Spacing.xs)
            make.width.height.equalTo(36)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        actionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackgroundView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-Spacing.xs)
        }
    }

    private func configure(with action: QuickActionType) {
        iconImageView.image = UIImage(systemName: action.iconName)
        iconImageView.tintColor = action.iconColor
        iconBackgroundView.backgroundColor = action.iconColor.withAlphaComponent(0.2)
        actionTitleLabel.text = action.title

        accessibilityLabel = action.title
        accessibilityTraits = [.button]
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.96, y: 0.96)
                    : .identity
                self.alpha = self.isHighlighted ? 0.9 : 1.0
            }
        }
    }
}
