//
//  AmountInputView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AmountInputView: UIView {

    private let amountRelay = BehaviorRelay<Int>(value: 0)

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "₩"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .kidkTextWhite.withAlphaComponent(0.6)
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .kidkTextWhite
        label.textAlignment = .left
        return label
    }()

    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkPink
        return view
    }()

    var amount: Observable<Int> {
        return amountRelay.asObservable()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(currencyLabel)
        addSubview(amountLabel)
        addSubview(underlineView)

        currencyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Spacing.lg)
            make.top.equalToSuperview().offset(Spacing.md)
        }

        amountLabel.snp.makeConstraints { make in
            make.leading.equalTo(currencyLabel.snp.trailing).offset(Spacing.xs)
            make.centerY.equalTo(currencyLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-Spacing.lg)
        }

        underlineView.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(Spacing.lg)
            make.height.equalTo(2)
            make.bottom.equalToSuperview().offset(-Spacing.md)
        }
    }

    func addDigit(_ digit: Int) {
        let currentAmount = amountRelay.value
        let newAmount = currentAmount * 10 + digit

        if newAmount <= 1000000 {
            amountRelay.accept(newAmount)
            updateDisplay(newAmount)
        }
    }

    func deleteDigit() {
        let currentAmount = amountRelay.value
        let newAmount = currentAmount / 10
        amountRelay.accept(newAmount)
        updateDisplay(newAmount)
    }

    func clear() {
        amountRelay.accept(0)
        updateDisplay(0)
    }

    private func updateDisplay(_ amount: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "0"
        amountLabel.text = formatted

        UIView.animate(withDuration: 0.1) {
            self.amountLabel.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.amountLabel.transform = .identity
            }
        }
    }
}
