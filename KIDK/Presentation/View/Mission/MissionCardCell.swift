//
//  MissionCardCell.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MissionCardCell: UITableViewCell {

    static let identifier = "MissionCardCell"

    var disposeBag = DisposeBag()

    private let missionCardView: MissionCardView = {
        let view = MissionCardView()
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(missionCardView)

        missionCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(Spacing.md)
            make.bottom.equalToSuperview().offset(-Spacing.xs)
        }
    }

    func configure(with mission: Mission?, isCollapsed: Bool) {
        missionCardView.configure(with: mission, isCollapsed: isCollapsed)
    }

    var collapseButtonTapped: Observable<Void> {
        missionCardView.collapseButtonTapped
    }

    var verifyButtonTapped: Observable<Void> {
        missionCardView.verifyButtonTapped
    }

    var whatMissionButtonTapped: Observable<Void> {
        missionCardView.whatMissionButtonTapped
    }
}
