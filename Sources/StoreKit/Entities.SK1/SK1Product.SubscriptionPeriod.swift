//
//  SK1Product.SubscriptionPeriod.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product {
    typealias SubscriptionPeriod = SKProductSubscriptionPeriod
}

extension SK1Product.SubscriptionPeriod {
    var asBotsiSubscriptionPeriod: BotsiSubscriptionPeriod {
         .init(unit: unit.asBotsiSubscriptionPeriodUnit, numberOfUnits: numberOfUnits)
    }
}
