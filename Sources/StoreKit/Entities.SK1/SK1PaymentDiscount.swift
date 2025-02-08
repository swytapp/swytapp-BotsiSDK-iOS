//
//  SK1PaymentDiscount.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

typealias SK1PaymentDiscount = SKPaymentDiscount

extension SK1PaymentDiscount {
    convenience init(offerId: String, signature: BotsiSubscriptionOffer.Signature) {
        self.init(
            identifier: offerId,
            keyIdentifier: signature.keyIdentifier,
            nonce: signature.nonce,
            signature: signature.signature.base64EncodedString(),
            timestamp: signature.timestamp as NSNumber
        )
    }
}
