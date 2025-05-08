//
//  BotsiOffer.swift
//  Botsi
//
//  Created by Vladyslav on 19.04.2025.
//

import Foundation

public struct BotsiOffer: Sendable, Hashable {
    /// A unique string that identifies this discount offer.
    public var identifier: String? { offerIdentifier.identifier }

    /// The category of this discount offer.
    public var offerType: OfferType { offerIdentifier.asOfferType }

    public let offerIdentifier: Identifier

    /// The duration unit for which the discount applies.
    public let subscriptionPeriod: BotsiSubscriptionPeriod

    /// How many consecutive periods the discount remains active.
    public let numberOfPeriods: Int

    /// The billing mode used for this discount.
    public let paymentMode: BotsiSubscriptionOffer.BotsiPaymentMode

    /// The subscription period formatted for the user’s locale.
    public let localizedSubscriptionPeriod: String?

    /// The count of periods formatted for the user’s locale.
    public let localizedNumberOfPeriods: String?

    /// The discounted price value in the local currency.
    public let price: Decimal

    /// The ISO currency code used when displaying the price.
    public let currencyCode: String?

    /// The localized display string for the discounted price.
    public var localizedPrice: String?

    init(
        price: Decimal,
        currencyCode: String?,
        localizedPrice: String?,
        offerIdentifier: Identifier,
        subscriptionPeriod: BotsiSubscriptionPeriod,
        numberOfPeriods: Int,
        paymentMode: BotsiSubscriptionOffer.BotsiPaymentMode,
        localizedSubscriptionPeriod: String?,
        localizedNumberOfPeriods: String?
    ) {
        self.price = price
        self.currencyCode = currencyCode
        self.localizedPrice = localizedPrice
        self.offerIdentifier = offerIdentifier
        self.subscriptionPeriod = subscriptionPeriod
        self.numberOfPeriods = numberOfPeriods
        self.paymentMode = paymentMode
        self.localizedSubscriptionPeriod = localizedSubscriptionPeriod
        self.localizedNumberOfPeriods = localizedNumberOfPeriods
    }
}

extension BotsiOffer: CustomStringConvertible {
    public var description: String {
        var summary = offerType.rawValue.capitalized
        if let id = identifier {
           summary += " [\(id)]"
        }
        let priceDisplay = localizedPrice ?? "\(price) \(currencyCode ?? "")"
        summary += ": \(priceDisplay)"
        summary += " • valid for \(numberOfPeriods)x \(subscriptionPeriod)"
        summary += " • mode: \(paymentMode)"
        return summary
    }
}

extension BotsiOffer {
    public enum Identifier: Sendable, Hashable {
        case introductory
        case promotional(String)
        case winBack(String)

        var identifier: String? {
            switch self {
            case .introductory: nil
            case let .promotional(value),
                 let .winBack(value):
                value
            }
        }

        var asOfferType: OfferType {
            switch self {
            case .introductory:
                .introductory
            case .promotional:
                .promotional
            case .winBack:
                .winBack
            }
        }
    }

    public enum OfferType: String, Sendable {
        /// A one-time introductory offer.
        case introductory
        /// A promotional offer for new or returning users.
        case promotional
        /// A discounted offer for re-engaging past subscribers.
        case winBack
    }
}
