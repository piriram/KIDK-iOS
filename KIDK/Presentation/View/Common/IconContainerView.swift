import UIKit
import SnapKit

final class IconContainerView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(
        _ iconName: String,
        backgroundColor: UIColor = .kidkTextWhite,
        size: CGFloat = 44,
        cornerRadius: CGFloat = 14,
        iconSize: CGFloat = 24,
        alpha: CGFloat = 0.2
    ) {
        super.init(frame: .zero)
        
        containerView.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        containerView.layer.cornerRadius = cornerRadius
        iconImageView.image = UIImage(named: iconName)
        
        setupUI(size: size, iconSize: iconSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(size: CGFloat, iconSize: CGFloat) {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(size)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(iconSize)
        }
    }
}
