//
//  FormatterCache.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/21/25.
//

import Foundation

/// DateFormatter와 NumberFormatter를 캐싱하여 재사용하는 유틸리티
/// Formatter 객체는 생성 비용이 높기 때문에 재사용을 권장합니다.
final class FormatterCache {

    // MARK: - Singleton
    static let shared = FormatterCache()
    private init() {}

    // MARK: - Date Formatters

    /// 시간 포맷 (예: "14:30")
    lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    /// 간단한 날짜 포맷 (예: "6월 7일")
    lazy var shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    /// 전체 날짜 포맷 (예: "2024년 6월 7일")
    lazy var fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    /// 날짜와 시간 포맷 (예: "6월 7일 14:30")
    lazy var dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    /// 월/일 포맷 (예: "06/07")
    lazy var monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    /// ISO 8601 포맷 (서버 통신용)
    lazy var iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    // MARK: - Number Formatters

    /// 화폐 포맷 (예: "12,450")
    lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    /// 퍼센트 포맷 (예: "85%")
    lazy var percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

// MARK: - Convenience Extensions

extension Date {
    /// 시간 포맷으로 변환 (예: "14:30")
    var formattedTime: String {
        return FormatterCache.shared.timeFormatter.string(from: self)
    }

    /// 간단한 날짜 포맷으로 변환 (예: "6월 7일")
    var formattedShortDate: String {
        return FormatterCache.shared.shortDateFormatter.string(from: self)
    }

    /// 전체 날짜 포맷으로 변환 (예: "2024년 6월 7일")
    var formattedFullDate: String {
        return FormatterCache.shared.fullDateFormatter.string(from: self)
    }

    /// 날짜와 시간 포맷으로 변환 (예: "6월 7일 14:30")
    var formattedDateTime: String {
        return FormatterCache.shared.dateTimeFormatter.string(from: self)
    }

    /// 월/일 포맷으로 변환 (예: "06/07")
    var formattedMonthDay: String {
        return FormatterCache.shared.monthDayFormatter.string(from: self)
    }
}

extension Int {
    /// 화폐 포맷으로 변환 (예: "12,450원")
    var formattedCurrency: String {
        let formatted = FormatterCache.shared.currencyFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
        return "\(formatted)원"
    }
}
