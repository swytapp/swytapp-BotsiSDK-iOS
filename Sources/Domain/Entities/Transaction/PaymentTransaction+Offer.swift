//
//  PaymentTransaction+Offer.swift
//  Botsi
//
//  Created by Vladyslav on 05.04.2025.
//

import StoreKit

public struct BotsiSubscriptionOffer: Sendable, CustomStringConvertible {
    
    public var description: String {
        return """
            Subscription Offer:
            
            id: \(id ?? "-")
            period: \(periodUnit.debugDescription)
            paymentMode: \(String(describing: type))
            offerType: \(String(describing: offerType))
            price: \(price ?? 0)
        """
    }
    
    public enum BotsiPaymentMode: String, Sendable {
        case payAsYouGo = "pay_as_you_go"
        case payUpFront = "pay_up_front"
        case freeTrial = "free_trial"
        case unknown = "unknown"
    }
    
    let id: String?
    let periodUnit: BotsiSubscriptionPeriod?
    let type: BotsiPaymentMode
    let offerType: BotsiPaymentTransaction.OfferType
    let price: Decimal?

    init(
        id: String,
        offerType: BotsiPaymentTransaction.OfferType
    ) {
        self.id = id
        periodUnit = nil
        type = .unknown
        self.offerType = offerType
        price = nil
    }
    
    init(
        id: String?,
        period: BotsiSubscriptionPeriod?,
        paymentMode: BotsiPaymentMode,
        offerType: BotsiPaymentTransaction.OfferType,
        price: Decimal?
    ) {
        self.id = id
        self.periodUnit = period
        self.type = paymentMode
        self.offerType = offerType
        self.price = price
    }
    
    init?(
        transaction: SKPaymentTransaction,
        product: SKProduct?
    ) {
        guard let offerId = transaction.transactionIdentifier else {
            let discount = product?.subscriptionOffer( // SKProductDiscount
                byType: .introductory
            )
            guard let discount else { return nil }

            self.init(
                id: nil,
                period: discount.subscriptionPeriod.toCustomPeriod,
                paymentMode: discount.paymentMode.asPaymentMode,
                offerType: .introductory,
                price: discount.price.decimalValue
            )
            return
        }

        let discount = product?.subscriptionOffer(
            byType: .promotional,
            withId: offerId
        )

        if let discount {
            self.init(
                id: discount.identifier,
                period: discount.subscriptionPeriod.toCustomPeriod,
                paymentMode: discount.paymentMode.asPaymentMode,
                offerType: .promotional,
                price: discount.price.decimalValue
            )
        } else {
            self.init(id: offerId, offerType: .promotional)
        }
    }
    
    @available(iOS 15.0, *)
    init?(
        transaction: Transaction,
        product: Product?
    ) {
        guard let offerType = transaction.unfOfferType?.asPurchasedTransactionOfferType else { return nil }
        let productOffer = product?.subscriptionOffer(
            byType: offerType,
            withId: transaction.unfOfferId
        )
        self = .init(
            id: transaction.unfOfferId,
            period: .init(
                unit: (productOffer?.period)?.unit.toPeriodUnit ?? .unknown,
                numberOfUnits: (productOffer?.period)?.value ?? 0
            ),
            paymentMode: (productOffer?.paymentMode)?.asPaymentMode ?? .unknown,
            offerType: offerType,
            price: productOffer?.price
        )
    }
}

/// `StoreKit 1 Offer`
extension SKProduct {
    func subscriptionOffer(
        byType offerType: BotsiPaymentTransaction.OfferType,
        withId offerId: String? = nil
    ) -> SKProductDiscount? {
        switch offerType {
        case .introductory:
            return introductoryPrice
        case .promotional:
            if let offerId {
                return discounts.first(where: { $0.identifier == offerId })
            }
        default:
            return nil
        }
        return nil
    }
}

@available(iOS 15.0, *)
extension Transaction.OfferType {
    var asPurchasedTransactionOfferType: BotsiPaymentTransaction.OfferType {
        guard let type = BotsiPaymentTransaction.OfferType(rawValue: rawValue) else {
            return .unknown
        }
        return type
    }
}
