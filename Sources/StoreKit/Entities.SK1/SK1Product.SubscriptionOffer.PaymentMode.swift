//
//  SK1Product.SubscriptionOffer.PaymentMode.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product.SubscriptionOffer.PaymentMode {
    var asPaymentMode: BotsiSubscriptionOffer.PaymentMode {
        switch self {
        case .payAsYouGo:
            .payAsYouGo
        case .payUpFront:
            .payUpFront
        case .freeTrial:
            .freeTrial
        @unknown default:
            .unknown
        }
    }
}
