import UIKit

final class MainTabBarController: UITabBarController {

    private enum TabSpec: CaseIterable {
        case account
        case mission
        case settings

        var title: String {
            switch self {
            case .account: return Strings.TabBar.account
            case .mission: return Strings.TabBar.mission
            case .settings: return Strings.TabBar.settings
            }
        }

        var unselectedAssetKey: String {
            switch self {
            case .account: return "tab_account_unselected"
            case .mission: return "tab_mission_unselected"
            case .settings: return "tab_settings_unselected"
            }
        }

        var selectedAssetKey: String {
            switch self {
            case .account: return "tab_account_selected"
            case .mission: return "tab_mission_selected"
            case .settings: return "tab_settings_selected"
            }
        }

        var fallbackUnselectedSystemName: String {
            switch self {
            case .account: return "wallet"
            case .mission: return "flag"
            case .settings: return "gearshape"
            }
        }

        var fallbackSelectedSystemName: String {
            switch self {
            case .account: return "wallet.fill"
            case .mission: return "flag.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    private let tabIconPointSize = CGSize(width: 24, height: 24)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
    }

    private func setupTabBarAppearance() {
        view.backgroundColor = .kidkDarkBackground

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .kidkDarkBackground

        let stacked = appearance.stackedLayoutAppearance
        stacked.normal.iconColor = .kidkGray
        stacked.normal.titleTextAttributes = [.foregroundColor: UIColor.kidkGray]
        stacked.selected.iconColor = .kidkPink
        stacked.selected.titleTextAttributes = [.foregroundColor: UIColor.kidkPink]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.tintColor = .kidkPink
        tabBar.unselectedItemTintColor = .kidkGray
        tabBar.isTranslucent = false
    }

    func configureTabBarItems() {
        guard let items = tabBar.items, items.count >= TabSpec.allCases.count else {
            #if DEBUG
            print("⚠️ Tab bar items not available")
            #endif
            return
        }

        for (index, spec) in TabSpec.allCases.enumerated() {
            let item = items[index]
            item.title = spec.title
            item.image = tabImage(
                assetName: spec.unselectedAssetKey,
                fallbackSystemName: spec.fallbackUnselectedSystemName
            )
            item.selectedImage = tabImage(
                assetName: spec.selectedAssetKey,
                fallbackSystemName: spec.fallbackSelectedSystemName
            )
        }
    }

    private func tabImage(assetName: String, fallbackSystemName: String) -> UIImage? {
        if let image = UIImage(named: assetName) {
            return normalizeTabIcon(image)
        }

        #if DEBUG
        print("⚠️ Tab icon fallback 사용: \(assetName) -> SF Symbol(\(fallbackSystemName))")
        #endif

        guard let fallback = UIImage(systemName: fallbackSystemName) else { return nil }
        return normalizeTabIcon(fallback)
    }

    private func normalizeTabIcon(_ image: UIImage) -> UIImage {
        let targetSize = tabIconPointSize
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let normalized = renderer.image { _ in
            let sourceSize = image.size
            guard sourceSize.width > 0, sourceSize.height > 0 else {
                image.draw(in: CGRect(origin: .zero, size: targetSize))
                return
            }

            let resizeScale = min(targetSize.width / sourceSize.width, targetSize.height / sourceSize.height)
            let drawSize = CGSize(
                width: sourceSize.width * resizeScale,
                height: sourceSize.height * resizeScale
            )
            let drawRect = pixelAlignedRect(
                centeredRect(for: drawSize, in: CGRect(origin: .zero, size: targetSize)),
                scale: format.scale
            )

            image.draw(in: drawRect)
        }

        #if DEBUG
        if normalized.size != tabIconPointSize {
            print("⚠️ Tab icon normalize failed: expected=\(tabIconPointSize), actual=\(normalized.size)")
        }
        #endif

        return normalized.withRenderingMode(.alwaysTemplate)
    }

    private func centeredRect(for contentSize: CGSize, in bounds: CGRect) -> CGRect {
        CGRect(
            x: (bounds.width - contentSize.width) / 2,
            y: (bounds.height - contentSize.height) / 2,
            width: contentSize.width,
            height: contentSize.height
        )
    }

    private func pixelAlignedRect(_ rect: CGRect, scale: CGFloat) -> CGRect {
        guard scale > 0 else { return rect }

        return CGRect(
            x: (rect.origin.x * scale).rounded() / scale,
            y: (rect.origin.y * scale).rounded() / scale,
            width: (rect.size.width * scale).rounded() / scale,
            height: (rect.size.height * scale).rounded() / scale
        )
    }
}
