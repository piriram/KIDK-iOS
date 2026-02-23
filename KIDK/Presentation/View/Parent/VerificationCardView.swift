import UIKit
import SnapKit

final class VerificationCardView: UIView {

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .bold)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s10, .regular)
        label.textColor = .kidkGray
        label.textAlignment = .center
        return label
    }()

    private let timelineDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkPink
        view.layer.cornerRadius = 5
        return view
    }()

    private let timelineLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBackground
        view.layer.cornerRadius = CornerRadius.large
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.kidkTextWhite.withAlphaComponent(0.06).cgColor
        return view
    }()

    private let typeBadgeView = ParentTimelineStatusBadgeView()
    private let statusBadgeView = ParentTimelineStatusBadgeView()

    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s18, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 2
        return label
    }()

    private let childNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s14, .medium)
        label.textColor = .kidkGray
        label.numberOfLines = 1
        return label
    }()

    private let submittedDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        label.numberOfLines = 1
        return label
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = CornerRadius.small
        imageView.backgroundColor = .kidkDarkBackground
        imageView.isHidden = true
        return imageView
    }()

    private var thumbnailBottomConstraint: Constraint?
    private var submittedBottomConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(dateLabel)
        addSubview(timeLabel)
        addSubview(timelineDotView)
        addSubview(timelineLineView)
        addSubview(containerView)

        containerView.addSubview(typeBadgeView)
        containerView.addSubview(statusBadgeView)
        containerView.addSubview(missionTitleLabel)
        containerView.addSubview(childNameLabel)
        containerView.addSubview(submittedDateLabel)
        containerView.addSubview(thumbnailImageView)

        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.sm)
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.width.equalTo(58)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(dateLabel)
        }

        timelineDotView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(Spacing.xxs)
            make.centerX.equalTo(dateLabel)
            make.size.equalTo(10)
        }

        timelineLineView.snp.makeConstraints { make in
            make.top.equalTo(timelineDotView.snp.bottom).offset(2)
            make.centerX.equalTo(timelineDotView)
            make.width.equalTo(2)
            make.bottom.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.equalTo(dateLabel.snp.trailing).offset(Spacing.xs)
            make.trailing.bottom.equalToSuperview()
        }

        typeBadgeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.sm)
            make.leading.equalToSuperview().offset(Spacing.sm)
        }

        statusBadgeView.snp.makeConstraints { make in
            make.top.equalTo(typeBadgeView)
            make.trailing.equalToSuperview().offset(-Spacing.sm)
            make.leading.greaterThanOrEqualTo(typeBadgeView.snp.trailing).offset(Spacing.xs)
        }

        missionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(typeBadgeView.snp.bottom).offset(Spacing.xs)
            make.leading.equalToSuperview().offset(Spacing.sm)
            make.trailing.equalToSuperview().offset(-Spacing.sm)
        }

        childNameLabel.snp.makeConstraints { make in
            make.top.equalTo(missionTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(missionTitleLabel)
            make.trailing.equalToSuperview().offset(-Spacing.sm)
        }

        submittedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(childNameLabel.snp.bottom).offset(Spacing.xxs)
            make.leading.trailing.equalTo(missionTitleLabel)
            submittedBottomConstraint = make.bottom.equalToSuperview().offset(-Spacing.sm).constraint
        }

        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalTo(submittedDateLabel.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalTo(missionTitleLabel)
            make.height.equalTo(120)
            thumbnailBottomConstraint = make.bottom.equalToSuperview().offset(-Spacing.sm).constraint
        }

        thumbnailBottomConstraint?.deactivate()
    }

    func configure(with verification: MissionVerification, missionTitle: String, showsConnector: Bool = true) {
        missionTitleLabel.text = missionTitle
        childNameLabel.text = "김시아"

        dateLabel.text = verification.submittedDate.formattedMonthDay
        timeLabel.text = verification.submittedDate.formattedTime
        submittedDateLabel.text = "제출: \(verification.formattedSubmittedDate)"

        typeBadgeView.configure(text: verification.type.displayName, tone: .blue)

        switch verification.status {
        case .pending:
            statusBadgeView.configure(text: "대기", tone: .pink)
        case .approved:
            statusBadgeView.configure(text: "승인", tone: .green)
        case .rejected:
            statusBadgeView.configure(text: "거절", tone: .red)
        }

        timelineDotView.backgroundColor = verification.status.color
        timelineLineView.isHidden = !showsConnector

        if verification.type == .photo, let photoPath = verification.content {
            thumbnailImageView.isHidden = false
            loadPhoto(from: photoPath)
            submittedBottomConstraint?.deactivate()
            thumbnailBottomConstraint?.activate()
        } else {
            thumbnailImageView.isHidden = true
            submittedBottomConstraint?.activate()
            thumbnailBottomConstraint?.deactivate()
        }
    }

    private func loadPhoto(from path: String) {
        let url = URL(fileURLWithPath: path)
        if let imageData = try? Data(contentsOf: url),
           let image = UIImage(data: imageData) {
            thumbnailImageView.image = image
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
            thumbnailImageView.tintColor = .kidkGray
        }
    }
}
