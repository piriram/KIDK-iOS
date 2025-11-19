//
//  ParentChildInfoViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

/// Phase 1: 플레이스홀더 화면
/// Phase 2: 자녀 프로필, 레벨, 미션 히스토리 등 표시
final class ParentChildInfoViewController: BaseViewController {

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "아이 정보\n(준비중)"
        label.font = .kidkFont(.s20, .bold)
        label.textColor = .kidkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }

    private func setupNavigationBar() {
        title = "아이 정보"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupUI() {
        view.backgroundColor = .kidkDarkBackground

        view.addSubview(placeholderLabel)

        placeholderLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
