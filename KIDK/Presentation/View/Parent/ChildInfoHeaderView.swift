import UIKit
import SnapKit

final class ChildInfoHeaderView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.medium
        return view
    }()

    private let profileImageView = ProfileImageView(
        assetName: "kidk_profile_one",
        size: 60,
        bgColor: .white,
        iconRatio: 0.7
    )

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s20, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        return label
    }()

    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.sm
        stackView.distribution = .fillEqually
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(infoStackView)

        infoStackView.addArrangedSubview(levelLabel)
        infoStackView.addArrangedSubview(pointsLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.md)
            make.centerY.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(Spacing.sm)
            make.top.equalToSuperview().offset(Spacing.md)
            make.trailing.lessThanOrEqualToSuperview().offset(-Spacing.md)
        }

        infoStackView.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(Spacing.sm)
            make.top.equalTo(nameLabel.snp.bottom).offset(Spacing.xxs)
            make.trailing.lessThanOrEqualToSuperview().offset(-Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        containerView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(90)
        }
    }

    func configure(name: String, level: Int, points: Int, profileImageURL: String? = nil) {
        nameLabel.text = name
        levelLabel.text = "Lv.\(level)"
        pointsLabel.text = "\(points) KP"

        // TODO: profileImageURL이 있으면 이미지 로드 로직 추가
        // 현재는 기본 프로필 이미지 사용
    }
}
