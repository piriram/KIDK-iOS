//
//  VerificationCardView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

final class VerificationCardView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#2C2C2E")
        view.layer.cornerRadius = CornerRadius.large
        return view
    }()

    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Spacing.xs
        stackView.alignment = .center
        return stackView
    }()

    private let typeIconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        return label
    }()

    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xxs
        return stackView
    }()

    private let missionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        label.numberOfLines = 1
        return label
    }()

    private let childNameLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        return label
    }()

    private let statusBadge: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textColor = .white
        return label
    }()

    private let submittedDateLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .regular)
        label.textColor = .kidkGray
        label.textAlignment = .right
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(containerView)
        containerView.addSubview(headerStackView)
        containerView.addSubview(submittedDateLabel)
        containerView.addSubview(thumbnailImageView)

        headerStackView.addArrangedSubview(typeIconLabel)
        headerStackView.addArrangedSubview(infoStackView)
        headerStackView.addArrangedSubview(statusBadge)

        infoStackView.addArrangedSubview(missionTitleLabel)
        infoStackView.addArrangedSubview(childNameLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerStackView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(Spacing.md)
            make.trailing.equalToSuperview().offset(-Spacing.md)
        }

        typeIconLabel.snp.makeConstraints { make in
            make.width.equalTo(32)
        }

        statusBadge.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(24)
        }

        submittedDateLabel.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
        }

        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalTo(submittedDateLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.height.equalTo(120)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }

        // Default constraint when thumbnail is hidden
        headerStackView.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualToSuperview().offset(-Spacing.md).priority(.high)
        }
    }

    func configure(with verification: MissionVerification, missionTitle: String) {
        // Type icon
        typeIconLabel.text = verification.type.icon

        // Mission title
        missionTitleLabel.text = missionTitle

        // Child name (hardcoded for Phase 1)
        childNameLabel.text = "김시아"

        // Status badge
        statusBadge.text = verification.status.displayName
        statusBadge.backgroundColor = verification.status.color

        // Submitted date
        submittedDateLabel.text = verification.formattedSubmittedDate

        // Thumbnail for photo verifications
        if verification.type == .photo, let photoPath = verification.content {
            thumbnailImageView.isHidden = false
            loadPhoto(from: photoPath)

            // Adjust constraints when thumbnail is visible
            submittedDateLabel.snp.remakeConstraints { make in
                make.top.equalTo(headerStackView.snp.bottom).offset(Spacing.xs)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
            }

            thumbnailImageView.snp.remakeConstraints { make in
                make.top.equalTo(submittedDateLabel.snp.bottom).offset(Spacing.sm)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
                make.height.equalTo(120)
                make.bottom.equalToSuperview().offset(-Spacing.md)
            }
        } else {
            thumbnailImageView.isHidden = true

            // Adjust constraints when thumbnail is hidden
            submittedDateLabel.snp.remakeConstraints { make in
                make.top.equalTo(headerStackView.snp.bottom).offset(Spacing.xs)
                make.leading.trailing.equalToSuperview().inset(Spacing.md)
                make.bottom.equalToSuperview().offset(-Spacing.md)
            }
        }
    }

    private func loadPhoto(from path: String) {
        let url = URL(fileURLWithPath: path)
        if let imageData = try? Data(contentsOf: url),
           let image = UIImage(data: imageData) {
            thumbnailImageView.image = image
        } else {
            // Fallback placeholder
            thumbnailImageView.image = UIImage(systemName: "photo")
            thumbnailImageView.tintColor = .kidkGray
        }
    }
}
