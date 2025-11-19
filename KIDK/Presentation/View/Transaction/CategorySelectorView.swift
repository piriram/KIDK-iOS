//
//  CategorySelectorView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CategorySelectorView: UIView {

    private let disposeBag = DisposeBag()
    private let categoryRelay = BehaviorRelay<TransactionCategory?>(value: nil)
    private var categoryButtons: [UIButton] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "무엇을 샀나요? (필수)"
        label.font = .kidkFont(.s16, .bold)
        label.textColor = .kidkTextWhite
        return label
    }()

    private let gridStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.sm
        stackView.distribution = .fillEqually
        return stackView
    }()

    var selectedCategory: Observable<TransactionCategory?> {
        return categoryRelay.asObservable()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(gridStackView)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        gridStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Spacing.md)
            make.leading.trailing.bottom.equalToSuperview()
        }

        let categories: [TransactionCategory] = [.food, .school, .game, .toy, .hobby, .transport, .culture, .etc]
        let rows = 2
        let itemsPerRow = 4

        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = Spacing.sm
            rowStack.distribution = .fillEqually

            for col in 0..<itemsPerRow {
                let index = row * itemsPerRow + col
                if index < categories.count {
                    let category = categories[index]
                    let button = makeCategoryButton(category: category)
                    categoryButtons.append(button)
                    rowStack.addArrangedSubview(button)
                }
            }

            gridStackView.addArrangedSubview(rowStack)
        }
    }

    private func makeCategoryButton(category: TransactionCategory) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(hex: "#2C2C2E")
        button.layer.cornerRadius = CornerRadius.medium

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Spacing.xxs
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false

        let emojiLabel = UILabel()
        emojiLabel.text = category.emoji
        emojiLabel.font = .systemFont(ofSize: 32)

        let nameLabel = UILabel()
        nameLabel.text = category.rawValue
        nameLabel.font = .kidkFont(.s14, .medium)
        nameLabel.textColor = .kidkTextWhite

        stackView.addArrangedSubview(emojiLabel)
        stackView.addArrangedSubview(nameLabel)

        button.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectCategory(category, button: button)
            })
            .disposed(by: disposeBag)

        return button
    }

    private func selectCategory(_ category: TransactionCategory, button: UIButton) {
        categoryButtons.forEach { btn in
            btn.backgroundColor = UIColor(hex: "#2C2C2E")
            btn.layer.borderWidth = 0
        }

        button.backgroundColor = category.color.withAlphaComponent(0.3)
        button.layer.borderWidth = 2
        button.layer.borderColor = category.color.cgColor

        categoryRelay.accept(category)
    }
}
