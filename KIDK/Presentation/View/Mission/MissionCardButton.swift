import UIKit
import SnapKit

final class MissionCardButton: UIControl {

    let missionType: MissionType

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2F2F36")
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        view.isUserInteractionEnabled = false
        return view
    }()

    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#24242B")
        view.layer.cornerRadius = 12
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .kidkPink
        return imageView
    }()

    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .bold)
        label.textColor = .kidkPink
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .semibold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .kidkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let arrowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        view.layer.cornerRadius = 10
        return view
    }()

    init(iconImage: UIImage?, badge: String, title: String, missionType: MissionType) {
        self.missionType = missionType
        super.init(frame: .zero)

        badgeLabel.text = badge
        titleLabel.text = title
        setIconImage(iconImage)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        containerView.addSubview(badgeLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowContainer)
        arrowContainer.addSubview(arrowImageView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        badgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconBackgroundView.snp.trailing).offset(Spacing.sm)
            make.top.equalToSuperview().offset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(badgeLabel)
            make.top.equalTo(badgeLabel.snp.bottom).offset(2)
            make.trailing.equalTo(arrowContainer.snp.leading).offset(-Spacing.xs)
        }

        arrowContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }

        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }
    }

    private func setIconImage(_ iconImage: UIImage?) {
        if let iconImage {
            iconImageView.image = iconImage
            iconImageView.tintColor = iconImage.isSymbolImage ? UIColor.kidkPink.withAlphaComponent(0.92) : nil
        } else {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
            iconImageView.image = fallbackSymbol(for: missionType)?.applyingSymbolConfiguration(symbolConfig)
            iconImageView.tintColor = UIColor.kidkPink.withAlphaComponent(0.92)
        }
    }

    private func fallbackSymbol(for missionType: MissionType) -> UIImage? {
        switch missionType {
        case .video:
            return UIImage(systemName: "play.rectangle.fill")
        case .study:
            return UIImage(systemName: "pencil")
        case .quiz:
            return UIImage(systemName: "character.book.closed")
        case .savings:
            return UIImage(systemName: "wallet.pass.fill")
        case .custom:
            return UIImage(systemName: "sparkles")
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.containerView.alpha = self.isHighlighted ? 0.75 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.985, y: 0.985) : .identity
            }
        }
    }
}
