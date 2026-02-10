import UIKit
import SnapKit

final class ProfileImageView: UIView {
    
    private let imageView = UIImageView()
    
    init(assetName: String, size: CGFloat, bgColor: UIColor,iconRatio: CGFloat) {
        super.init(frame: .zero)
        
        backgroundColor = bgColor
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.image = UIImage(named: assetName)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        snp.makeConstraints { make in
            make.width.height.equalTo(size)
        }
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(size * iconRatio)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        imageView.layer.cornerRadius = imageView.bounds.width / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
