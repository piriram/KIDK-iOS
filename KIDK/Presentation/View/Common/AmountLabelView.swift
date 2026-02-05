//
//  AmountLabelView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import UIKit
import SnapKit

final class AmountLabelView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#242426")
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkBody
        label.textColor = .kidkTextWhite
        label.textAlignment = .center
        return label
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
        containerView.addSubview(amountLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.small)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(amount: String) {
        amountLabel.text = amount
    }
}
