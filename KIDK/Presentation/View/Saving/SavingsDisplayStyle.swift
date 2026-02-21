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
        case .warmKids: return UIColor(hex: "#2A1F2B")
        }
    }

    var primaryAccentColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkBlue
        case .bentoDashboard: return UIColor(hex: "#8B7CFF")
        case .warmKids: return UIColor(hex: "#FF7A7A")
        }
    }

    var secondaryAccentColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGreen
        case .bentoDashboard: return .kidkPink
        case .warmKids: return UIColor(hex: "#FFB64D")
        }
    }

    var headerGradientColors: [UIColor] {
        switch self {
        case .neoBankClean:
            return [UIColor(hex: "#2D3A52"), UIColor(hex: "#232934"), UIColor(hex: "#1D212A")]
        case .bentoDashboard:
            return [UIColor(hex: "#3A2A63"), UIColor(hex: "#28345D"), UIColor(hex: "#202437")]
        case .warmKids:
            return [UIColor(hex: "#5B2D4F"), UIColor(hex: "#3E2E56"), UIColor(hex: "#2A2239")]
        }
    }

    var headerBorderColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.10)
        case .bentoDashboard: return UIColor(hex: "#8B7CFF").withAlphaComponent(0.45)
        case .warmKids: return UIColor(hex: "#FF9C5B").withAlphaComponent(0.40)
        }
    }

    var headerIconBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.16)
        case .bentoDashboard: return UIColor(hex: "#8B7CFF").withAlphaComponent(0.28)
        case .warmKids: return UIColor(hex: "#FF9C5B").withAlphaComponent(0.28)
        }
    }

    var summaryTextColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.80)
        case .bentoDashboard: return UIColor(hex: "#D7D9FF")
        case .warmKids: return UIColor(hex: "#FFE4D3")
        }
    }

    var statCardBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.06)
        case .bentoDashboard: return UIColor(hex: "#2E3250")
        case .warmKids: return UIColor(hex: "#463050")
        }
    }

    var statCardBorderColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.08)
        case .bentoDashboard: return UIColor(hex: "#8B7CFF").withAlphaComponent(0.38)
        case .warmKids: return UIColor(hex: "#FF9C5B").withAlphaComponent(0.34)
        }
    }

    var statTitleColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGray
        case .bentoDashboard: return UIColor(hex: "#C3C8FF")
        case .warmKids: return UIColor(hex: "#FAD8C0")
        }
    }

    var sectionTitleColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkTextWhite
        case .bentoDashboard: return UIColor(hex: "#F3F4FF")
        case .warmKids: return UIColor(hex: "#FFF0E7")
        }
    }

    var sectionSubtitleColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGray
        case .bentoDashboard: return UIColor(hex: "#B9BFF3")
        case .warmKids: return UIColor(hex: "#F3C8B2")
        }
    }

    var goalCardBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor(hex: "#2A2E38")
        case .bentoDashboard: return UIColor(hex: "#262B43")
        case .warmKids: return UIColor(hex: "#3A2B44")
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
        case .warmKids: return UIColor(hex: "#F7D3C4")
        }
    }

    var emptyCardBackgroundColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor(hex: "#2A2E38")
        case .bentoDashboard: return UIColor(hex: "#252A41")
        case .warmKids: return UIColor(hex: "#3A2B44")
        }
    }

    var emptyCardBorderColor: UIColor {
        switch self {
        case .neoBankClean: return UIColor.white.withAlphaComponent(0.06)
        case .bentoDashboard: return UIColor(hex: "#8B7CFF").withAlphaComponent(0.30)
        case .warmKids: return UIColor(hex: "#FF9C5B").withAlphaComponent(0.28)
        }
    }

    var emptyIconColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkGray
        case .bentoDashboard: return UIColor(hex: "#B2B9FF")
        case .warmKids: return UIColor(hex: "#FFC28A")
        }
    }

    var primaryButtonColor: UIColor {
        switch self {
        case .neoBankClean: return .kidkBlue
        case .bentoDashboard: return UIColor(hex: "#8B7CFF")
        case .warmKids: return UIColor(hex: "#FF8E6E")
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
            return UIColor(hex: "#FF9C5B")
        case (.warmKids, .completed):
            return UIColor(hex: "#FFD166")
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
