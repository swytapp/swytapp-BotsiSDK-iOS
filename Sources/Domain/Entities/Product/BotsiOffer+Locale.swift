//
//  BotsiOffer+Locale.swift
//  Botsi
//
//  Created by Vladyslav on 19.04.2025.
//

import Foundation

extension Locale {
    @inlinable
    func localized(sk1Price price: NSDecimalNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self
        return formatter.string(from: price)
    }
    
    @inlinable
    var unfCurrencyCode: String? {
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, visionOS 1.0, *) {
            currency?.identifier
        } else {
            currencyCode
        }
    }
    
    @inlinable
    var unfRegionCode: String? {
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, visionOS 1.0, *) {
            region?.identifier
        } else {
            regionCode
        }
    }

    @inlinable
    var unfLanguageCode: String? {
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, visionOS 1.0, *) {
            language.languageCode?.identifier
        } else {
            languageCode
        }
    }

    func localized(period: BotsiSubscriptionPeriod, numberOfPeriods: Int = 1) -> String? {
        let countUnits = period.numberOfUnits * numberOfPeriods
        switch period.unit {
        case .day:
            if numberOfPeriods == 1, countUnits == 7 { return localizedComponents(weekOfMonth: 1) }
            return localizedComponents(day: countUnits)
        case .week:
            return localizedComponents(weekOfMonth: countUnits)
        case .month:
            return localizedComponents(month: countUnits)
        case .year:
            return localizedComponents(year: countUnits)
        default:
            return nil
        }
    }

    private func localizedComponents(day: Int? = nil, weekOfMonth: Int? = nil, month: Int? = nil, year: Int? = nil) -> String? {
        var calendar = Calendar.current
        calendar.locale = self

        var components = DateComponents(calendar: calendar)
        components.day = day
        components.weekOfMonth = weekOfMonth
        components.month = month
        components.year = year

        return DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
    }
}
