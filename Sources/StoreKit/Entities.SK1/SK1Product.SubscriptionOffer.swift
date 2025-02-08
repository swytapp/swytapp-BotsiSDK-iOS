//
//  SK1Product.SubscriptionOffer.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product {
    typealias SubscriptionOffer = SKProductDiscount

    var introductoryOfferNotApplicable: Bool {
        if let period = subscriptionPeriod,
           period.numberOfUnits > 0,
           introductoryPrice != nil
        {
            false
        } else {
            true
        }
    }

    private var unfIntroductoryOffer: SK1Product.SubscriptionOffer? {
        introductoryPrice
    }

    private func unfPromotionalOffer(byId identifier: String) -> SK1Product.SubscriptionOffer? {
        discounts.first(where: { $0.identifier == identifier })
    }

    func subscriptionOffer(by offerIdentifier: BotsiSubscriptionOffer.Identifier) -> BotsiSubscriptionOffer? {
        let offer: SK1Product.SubscriptionOffer? =
            switch offerIdentifier {
            case .introductory:
                unfIntroductoryOffer
            case .promotional(let id):
                unfPromotionalOffer(byId: id)
            default:
                nil
            }
        guard let offer else { return nil }

        let locale = priceLocale
        let period = offer.subscriptionPeriod.asBotsiSubscriptionPeriod
        return BotsiSubscriptionOffer(
            price: offer.price as Decimal,
            currencyCode: locale.unfCurrencyCode,
//            currencySymbol: locale.currencySymbol,
            localizedPrice: locale.localized(sk1Price: offer.price),
            offerIdentifier: offerIdentifier,
            subscriptionPeriod: period,
            numberOfPeriods: offer.numberOfPeriods,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: locale.localized(period: period),
            localizedNumberOfPeriods: locale.localized(period: period, numberOfPeriods: offer.numberOfPeriods)
        )
    }
}
