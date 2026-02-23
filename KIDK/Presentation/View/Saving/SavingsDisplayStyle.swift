import UIKit

enum SavingsDisplayStyle: Int, CaseIterable {
    case neoBankClean
    case bentoDashboard
    case warmKids

    var segmentTitle: String {
        switch self {
        case .neoBankClean: return "Neo"
        case .bentoDashboard: return "Bento"
        case .warmKids: return "Warm"
        }
    }

    var screenBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor(hex: "#1F2229")
        case .bentoDashboard: return UIColor(hex: "#1B1C24")
        case .warmKids: return UIColor(hex: "#2B1E29")
        }
    }

    var primaryAccentColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkBlue
        case .bentoDashboard: return UIColor(hex: "#8B7CFF")
        case .warmKids: return .kidkPink
        }
    }

    var secondaryAccentColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGreen
        case .bentoDashboard: return .kidkPink
        case .warmKids: return UIColor(hex: "#FF9BC7")
        }
    }

    var headerGradientColors: [UIColor] {
        switch self {
        case .neoBankClean:
            return [UIColor(hex: "#2D3A52"), UIColor(hex: "#232934"), UIColor(hex: "#1D212A")]
        case .bentoDashboard:
            return [UIColor(hex: "#3A2A63"), UIColor(hex: "#28345D"), UIColor(hex: "#202437")]
        case .warmKids:
            return [UIColor(hex: "#5A2848"), UIColor(hex: "#4A2742"), UIColor(hex: "#342131")]
        }
    }

    var headerBorderColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.10)
        case .bentoDashboard: return UIColor(hex: "#8B7CFF").withAlphaComponent(0.45)
        case .warmKids: return UIColor(hex: "#FF8FC2").withAlphaComponent(0.42)
        }
    }

    var headerIconBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.16)
        case .bentoDashboard: return UIColor(hex: "#8B7CFF").withAlphaComponent(0.28)
        case .warmKids: return UIColor(hex: "#FF8FC2").withAlphaComponent(0.28)
        }
    }

    var summaryTextColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.80)
        case .bentoDashboard: return UIColor(hex: "#D7D9FF")
        case .warmKids: return UIColor(hex: "#FFDDF0")
        }
    }

    var statCardBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.06)
        case .bentoDashboard: return UIColor(hex: "#2E3250")
        case .warmKids: return UIColor(hex: "#44283D")
        }
    }

    var statCardBorderColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.08)
        case .bentoDashboard: return UIColor(hex: "#8B7CFF").withAlphaComponent(0.38)
        case .warmKids: return UIColor(hex: "#FF9BC7").withAlphaComponent(0.36)
        }
    }

    var statTitleColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGray
        case .bentoDashboard: return UIColor(hex: "#C3C8FF")
        case .warmKids: return UIColor(hex: "#F9CDE4")
        }
    }

    var sectionTitleColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkTextWhite
        case .bentoDashboard: return UIColor(hex: "#F3F4FF")
        case .warmKids: return UIColor(hex: "#FFEAF5")
        }
    }

    var sectionSubtitleColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGray
        case .bentoDashboard: return UIColor(hex: "#B9BFF3")
        case .warmKids: return UIColor(hex: "#F2BDD8")
        }
    }

    var goalCardBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor(hex: "#2A2E38")
        case .bentoDashboard: return UIColor(hex: "#262B43")
        case .warmKids: return UIColor(hex: "#4A2A40")
        }
    }

    var goalCardTrackColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.12)
        case .bentoDashboard: return UIColor.white.withAlphaComponent(0.16)
        case .warmKids: return UIColor.white.withAlphaComponent(0.16)
        }
    }

    var goalCardSecondaryTextColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGray
        case .bentoDashboard: return UIColor(hex: "#C4C9F3")
        case .warmKids: return UIColor(hex: "#F8D7E8")
        }
    }

    var emptyCardBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor(hex: "#2A2E38")
        case .bentoDashboard: return UIColor(hex: "#252A41")
        case .warmKids: return UIColor(hex: "#43263A")
        }
    }

    var emptyCardBorderColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.06)
        case .bentoDashboard: return UIColor(hex: "#8B7CFF").withAlphaComponent(0.30)
        case .warmKids: return UIColor(hex: "#FF9BC7").withAlphaComponent(0.30)
        }
    }

    var emptyIconColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGray
        case .bentoDashboard: return UIColor(hex: "#B2B9FF")
        case .warmKids: return UIColor(hex: "#FFB6D8")
        }
    }

    var primaryButtonColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkBlue
        case .bentoDashboard: return UIColor(hex: "#8B7CFF")
        case .warmKids: return .kidkPink
        }
    }

    func accentColor(for status: SavingsGoalStatus) -> UIColor {
        switch (self, status) {
        case (_, .cancelled):
            return .kidkGray
        case (.neoBankClean, .inProgress):
            return .kidkBlue
        case (.neoBankClean, .completed):
            return .kidkGreen
        case (.bentoDashboard, .inProgress):
            return UIColor(hex: "#8B7CFF")
        case (.bentoDashboard, .completed):
            return .kidkPink
        case (.warmKids, .inProgress):
            return .kidkPink
        case (.warmKids, .completed):
            return UIColor(hex: "#FF9BC7")
        }
    }

    func statusBadgeColor(for status: SavingsGoalStatus) -> UIColor {
        switch status {
        case .inProgress:
            return secondaryAccentColor
        case .completed:
            return accentColor(for: .completed)
        case .cancelled:
            return .kidkGray
        }
    }

    func statusBadgeBackground(for status: SavingsGoalStatus) -> UIColor {
        statusBadgeColor(for: status).withAlphaComponent(0.22)
    }

    func dDayColor(daysRemaining: Int) -> UIColor {
        if daysRemaining > 0 { return primaryAccentColor }
        if daysRemaining == 0 { return secondaryAccentColor }
        return .kidkGray
    }

    func dDayBackground(daysRemaining: Int) -> UIColor {
        dDayColor(daysRemaining: daysRemaining).withAlphaComponent(0.22)
    }
}
