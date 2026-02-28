import UIKit
import SnapKit

final class CircularProgressView: UIView {

    private let backgroundCircleLayer = CAShapeLayer()
    private let progressCircleLayer = CAShapeLayer()
    private let progressGradientLayer = CAGradientLayer()

    private let centerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let completionBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkFont(.s12, .bold)
        label.textColor = .kidkTextWhite
        label.backgroundColor = .kidkGreen
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.text = "완료"
        label.isHidden = true
        return label
    }()

    private let lineWidth: CGFloat = 22
    private let backgroundCircleColor: UIColor = .kidkDarkBackground.withAlphaComponent(0.85)
    private let startDegree: CGFloat = 240
    private let sweepDegree: CGFloat = 240

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
        layer.addSublayer(progressGradientLayer)

        addSubview(centerImageView)
        addSubview(amountLabel)
        addSubview(completionBadgeLabel)

        backgroundCircleLayer.fillColor = UIColor.clear.cgColor
        backgroundCircleLayer.strokeColor = backgroundCircleColor.cgColor
        backgroundCircleLayer.lineWidth = lineWidth
        backgroundCircleLayer.lineCap = .round
        backgroundCircleLayer.contentsScale = UIScreen.main.scale

        progressCircleLayer.fillColor = UIColor.clear.cgColor
        progressCircleLayer.strokeColor = UIColor.kidkPink.cgColor
        progressCircleLayer.lineWidth = lineWidth
        progressCircleLayer.lineCap = .round
        progressCircleLayer.strokeEnd = 0
        progressCircleLayer.contentsScale = UIScreen.main.scale

        progressGradientLayer.mask = progressCircleLayer
        progressGradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        progressGradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)
        progressGradientLayer.colors = [
            UIColor.kidkPink.cgColor,
            UIColor.kidkPink.cgColor
        ]

        amountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(74)
        }

        centerImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(Spacing.xl)
            make.width.equalTo(196)
            make.height.equalTo(132)
        }

        completionBadgeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(centerImageView.snp.top).offset(-10)
            make.height.equalTo(28)
            make.width.greaterThanOrEqualTo(72)
        }
    }

    private func updateCirclePaths() {
        progressGradientLayer.frame = bounds
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (min(bounds.width, bounds.height) - lineWidth) / 2
        let startAngle = radiansFromTop(deg: startDegree)
        let endAngle = radiansFromTop(deg: startDegree + sweepDegree)

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
        image: UIImage?,
        accentColor: UIColor = .kidkPink,
        showsCompletionBadge: Bool = false
    ) {
        amountLabel.isHidden = false
        completionBadgeLabel.isHidden = !showsCompletionBadge
        completionBadgeLabel.backgroundColor = accentColor

        let percentage = targetAmount > 0
            ? min(Double(currentAmount) / Double(targetAmount), 1.0)
            : 0

        let formattedCurrent = FormatterCache.shared.currencyFormatter
            .string(from: NSNumber(value: currentAmount)) ?? "\(currentAmount)"
        let formattedTarget = FormatterCache.shared.currencyFormatter
            .string(from: NSNumber(value: targetAmount)) ?? "\(targetAmount)"

        let amountText = "\(formattedCurrent)원"
        let amountAttributedString = NSMutableAttributedString(
            string: amountText,
            attributes: [
                .font: UIFont.kidkTitleEn,
                .foregroundColor: UIColor.kidkTextWhite
            ]
        )
        let targetAttributedString = NSAttributedString(
            string: " / \(formattedTarget)원",
            attributes: [
                .font: UIFont.kidkBodyEn,
                .foregroundColor: UIColor.kidkGray
            ]
        )
        amountAttributedString.append(targetAttributedString)
        amountLabel.attributedText = amountAttributedString
        centerImageView.image = image

        progressGradientLayer.colors = [accentColor.cgColor, accentColor.cgColor]
        progressCircleLayer.strokeColor = accentColor.cgColor

        setProgress(to: CGFloat(percentage), animated: true)
    }

    func configureEmpty(image: UIImage?) {
        amountLabel.isHidden = true
        completionBadgeLabel.isHidden = true
        centerImageView.image = image
        progressGradientLayer.colors = [UIColor.kidkPink.cgColor, UIColor.kidkPink.cgColor]
        progressCircleLayer.strokeColor = UIColor.kidkPink.cgColor
        setProgress(to: 0, animated: false)
    }

    private func radiansFromTop(deg: CGFloat) -> CGFloat {
        let adjusted = deg - 90
        return adjusted * .pi / 180
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
