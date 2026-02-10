import UIKit
import SnapKit

final class AmountLabelView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .kidkDarkBackground
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let triangleView: TriangleView = {
        let view = TriangleView()
        view.backgroundColor = .clear
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
        addSubview(triangleView)
        addSubview(containerView)
        containerView.addSubview(amountLabel)
        
        triangleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(12)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(triangleView.snp.trailing)
            make.top.trailing.bottom.equalToSuperview()
        }
        
        amountLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Spacing.xs)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(amount: String) {
        amountLabel.text = amount
    }
}

final class TriangleView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: rect.height / 2))
        context.addLine(to: CGPoint(x: rect.width, y: 0))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height))
        context.closePath()
        
        context.setFillColor(UIColor.kidkDarkBackground.cgColor)
        context.fillPath()
    }
}
