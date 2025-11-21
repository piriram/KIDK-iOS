//
//  SavingsProgressBar.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit

final class SavingsProgressBar: UIView {

    private let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1C1C1E")
        view.layer.cornerRadius = 4
        return view
    }()

    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkGreen
        view.layer.cornerRadius = 4
        return view
    }()

    private var progressWidthConstraint: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(trackView)
        trackView.addSubview(progressView)

        trackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(8)
        }

        progressView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            progressWidthConstraint = make.width.equalTo(0).constraint
        }
    }

    func setProgress(_ progress: Double, animated: Bool = true) {
        let clampedProgress = min(max(progress, 0), 1)
        layoutIfNeeded()

        let targetWidth = trackView.bounds.width * CGFloat(clampedProgress)

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.progressWidthConstraint?.update(offset: targetWidth)
                self.layoutIfNeeded()
            }
        } else {
            progressWidthConstraint?.update(offset: targetWidth)
        }
    }

    func setProgressColor(_ color: UIColor) {
        progressView.backgroundColor = color
    }
}
