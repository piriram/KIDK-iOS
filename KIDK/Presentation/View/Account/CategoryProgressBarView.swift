//
//  CategoryProgressBarView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/15/25.
//
import UIKit
import SnapKit

class CategoryProgressBarView: UIView {
    
    private var barViews: [UIView] = []
    private var barWidthConstraints: [Constraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
    }
    
    func configure(with categories: [CategorySpending], animated: Bool = true) {
        clearBars()
        
        let processedCategories = processCategories(categories)
        
        guard !processedCategories.isEmpty else { return }
        
        var previousBar: UIView?
        
        for (index, category) in processedCategories.enumerated() {
            let bar = createBar(for: category, at: index, isLast: index == processedCategories.count - 1)
            barViews.append(bar)
            addSubview(bar)
            
            bar.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.height.equalTo(ProgressBarConfig.barHeight)
                
                if let previous = previousBar {
                    make.leading.equalTo(previous.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
                
                if index == processedCategories.count - 1 {
                    make.trailing.equalToSuperview()
                }
                
                let constraint = make.width.equalToSuperview().multipliedBy(0).constraint
                barWidthConstraints.append(constraint)
            }
            
            previousBar = bar
        }
        
        layoutIfNeeded()
        
        if animated {
            animateBars(with: processedCategories)
        } else {
            updateBarWidths(with: processedCategories, animated: false)
        }
    }
    
    private func createBar(for category: CategorySpending, at index: Int, isLast: Bool) -> UIView {
        let bar = UIView()
        bar.backgroundColor = category.color
        
        if index == 0 {
            bar.layer.cornerRadius = ProgressBarConfig.barCornerRadius
            bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else if isLast {
            bar.layer.cornerRadius = ProgressBarConfig.barCornerRadius
            bar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
        
        return bar
    }
    
    private func processCategories(_ categories: [CategorySpending]) -> [CategorySpending] {
        let sortedCategories = categories.sorted { $0.percentage > $1.percentage }
        
        var visibleCategories: [CategorySpending] = []
        var othersAmount = 0
        var othersPercentage: Double = 0
        
        for (index, category) in sortedCategories.enumerated() {
            if index < ProgressBarConfig.maxVisibleCategories {
                let color = ProgressBarConfig.brandColors[index % ProgressBarConfig.brandColors.count]
                let updatedCategory = CategorySpending(
                    category: category.category,
                    amount: category.amount,
                    totalAmount: Int(Double(category.amount) / category.percentage),
                    color: color
                )
                visibleCategories.append(updatedCategory)
            } else {
                othersAmount += category.amount
                othersPercentage += category.percentage
            }
        }
        
        if othersAmount > 0 {
            let totalAmount = visibleCategories.isEmpty ? othersAmount : Int(Double(othersAmount) / othersPercentage)
            let othersCategory = CategorySpending(
                category: "기타",
                amount: othersAmount,
                totalAmount: totalAmount,
                color: ProgressBarConfig.othersColor
            )
            visibleCategories.append(othersCategory)
        }
        
        return visibleCategories
    }
    
    private func animateBars(with categories: [CategorySpending]) {
        let style = ProgressBarConfig.animationStyle
        
        style.animate { [weak self] in
            self?.updateBarWidths(with: categories, animated: true)
        }
    }
    
    private func updateBarWidths(with categories: [CategorySpending], animated: Bool) {
        for (index, category) in categories.enumerated() {
            guard index < barViews.count else { break }
            
            barViews[index].snp.remakeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.height.equalTo(ProgressBarConfig.barHeight)
                
                if index == 0 {
                    make.leading.equalToSuperview()
                } else {
                    make.leading.equalTo(barViews[index - 1].snp.trailing)
                }
                
                if index == categories.count - 1 {
                    make.trailing.equalToSuperview()
                }
                
                make.width.equalToSuperview().multipliedBy(category.percentage)
            }
        }
        
        if animated {
            layoutIfNeeded()
        }
    }
    
    private func clearBars() {
        barViews.forEach { $0.removeFromSuperview() }
        barViews.removeAll()
        barWidthConstraints.removeAll()
    }
}
