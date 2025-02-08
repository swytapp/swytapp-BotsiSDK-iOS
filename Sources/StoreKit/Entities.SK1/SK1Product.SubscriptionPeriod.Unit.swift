//
//  SK1Product.SubscriptionPeriod.Unit.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product.SubscriptionPeriod {
    typealias Unit = SKProduct.PeriodUnit
}

extension SK1Product.SubscriptionPeriod.Unit {
    var asBotsiSubscriptionPeriodUnit: BotsiSubscriptionPeriod.Unit {
        switch self {
        case .day: .day
        case .week: .week
        case .month: .month
        case .year: .year
        @unknown default: .unknown
        }
    }
}
