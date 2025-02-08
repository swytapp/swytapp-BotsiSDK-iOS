//
//  BotsiDeferredProduct.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public final class BotsiDeferredProduct: @unchecked Sendable {
    public var subscriptionOffer: BotsiSubscriptionOffer? {
        guard let promotionalOfferId = payment.paymentDiscount?.identifier else { return nil }
        return skProduct.subscriptionOffer(by: .promotional(promotionalOfferId))
    }

    let payment: SKPayment
    let skProduct: SK1Product

    init(sk1Product: SK1Product, payment: SKPayment) {
        self.payment = payment
        self.skProduct = sk1Product
    }
}

extension BotsiDeferredProduct: BotsiSK1Product {}
