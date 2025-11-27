import UIKit
import SnapKit

final class CategorySpendingView: UIView {
    
    private let iconContainerView: IconContainerView
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .kidkSubtitle
        label.textColor = .kidkTextWhite
        return label
    }()
    
    private let amountView = AmountLabelView()
    
    init(iconName: String, backgroundColor: UIColor) {
        self.iconContainerView = IconContainerView(iconName, backgroundColor: backgroundColor, alpha: 0.2)
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(iconContainerView)
        addSubview(titleLabel)
        addSubview(amountView)
        
        iconContainerView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainerView.snp.trailing).offset(Spacing.xs)
            make.centerY.equalToSuperview()
        }
        
        amountView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    func configure(title: String, amount: Int) {
        titleLabel.text = title
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        amountView.configure(amount: "\(formatted)원")
    }
}
