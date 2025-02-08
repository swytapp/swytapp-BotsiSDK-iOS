//
//  SK2Product.SubscriptionOffer.PaymentMode.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Product.SubscriptionOffer.PaymentMode {
    var asPaymentMode: BotsiSubscriptionOffer.PaymentMode {
        switch self {
        case .payAsYouGo:
            .payAsYouGo
        case .payUpFront:
            .payUpFront
        case .freeTrial:
            .freeTrial
        default:
            .unknown
        }
    }
}
