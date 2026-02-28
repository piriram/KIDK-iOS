import Foundation

extension Int {
    var formattedWithComma: String {
        return FormatterCache.shared.currencyFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
