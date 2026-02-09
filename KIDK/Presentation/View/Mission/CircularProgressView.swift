//
//  CircularProgressView.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/18/25.
//

import UIKit
import SnapKit

final class CircularProgressView: UIView {
    
    private let backgroundCircleLayer = CAShapeLayer()
    private let progressCircleLayer = CAShapeLayer()
    
    private let centerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let targetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .kidkFont(.s14, .regular)
        label.textColor = .kidkGray
        return label
    }()
    
    private var lineWidth: CGFloat = 12
    private var progressColor: UIColor = .kidkPink
    private var backgroundCircleColor: UIColor = UIColor(hex: "#1C1C1E")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCirclePaths()
    }
    
    private func setupUI() {
        layer.addSublayer(backgroundCircleLayer)
        layer.addSublayer(progressCircleLayer)
        
        addSubview(centerImageView)
        addSubview(amountLabel)
        addSubview(targetLabel)
        
        backgroundCircleLayer.fillColor = UIColor.clear.cgColor
        backgroundCircleLayer.strokeColor = backgroundCircleColor.cgColor
        backgroundCircleLayer.lineWidth = lineWidth
        backgroundCircleLayer.lineCap = .round
        
        progressCircleLayer.fillColor = UIColor.clear.cgColor
        progressCircleLayer.strokeColor = progressColor.cgColor
        progressCircleLayer.lineWidth = lineWidth
        progressCircleLayer.lineCap = .round
        progressCircleLayer.strokeEnd = 0
        
        centerImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(Spacing.md)
            make.width.height.equalTo(140)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Spacing.lg)
        }
        
        targetLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(amountLabel.snp.bottom).offset(Spacing.xxs)
        }
    }
    
    private func updateCirclePaths() {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let startAngle = CGFloat.pi
        let endAngle = CGFloat.pi * 2
        
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        backgroundCircleLayer.path = circularPath.cgPath
        progressCircleLayer.path = circularPath.cgPath
    }
    
    func configure(
        currentAmount: Int,
        targetAmount: Int,
        image: UIImage?
    ) {
        let percentage = min(Double(currentAmount) / Double(targetAmount), 1.0)
        
        let amountText = "\(currentAmount.formattedWithComma)원"
        let targetText = "/\(targetAmount.formattedWithComma)원"
        
        let amountAttributedString = NSMutableAttributedString(
            string: amountText,
            attributes: [
                .font: UIFont.kidkFont(.s24, .bold),
                .foregroundColor: UIColor.kidkTextWhite
            ]
        )
        
        amountLabel.attributedText = amountAttributedString
        targetLabel.text = targetText
        centerImageView.image = image
        
        setProgress(to: CGFloat(percentage), animated: true)
    }
    
    private func setProgress(to progress: CGFloat, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressCircleLayer.strokeEnd
            animation.toValue = progress
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressCircleLayer.add(animation, forKey: "progressAnimation")
        }
        
        progressCircleLayer.strokeEnd = progress
    }
}

extension Int {
    var formattedWithComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
