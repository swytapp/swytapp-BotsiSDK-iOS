//
//  BotsiProduct.swift
//  Botsi
//
//  Created by Vladyslav on 23.03.2025.
//

import StoreKit

public protocol BotsiProduct: Sendable, CustomStringConvertible {
    
    var sk1Product: SKProduct? { get }
    
    @available(iOS 15.0, macOS 12.0, *)
    var sk2Product: Product? { get }
    
    var paywallId: Int { get }
    var abTestId: Int? { get }
    var productId: String { get }
    var placementId: String? { get }
    
    var title: String { get }
    var descriptionText: String { get }
    
    var price: Decimal { get }
    var currencyCode: String? { get }
    var localizedPrice: String? { get }
    
    var isEligibleForIntroOffer: Bool { get }
    var introductoryPrice: String? { get }
    
    var subscriptionGroupIdentifier: String? { get }
    var localizedSubscriptionPeriod: String? { get }
    
    var subscriptionOffer: BotsiOffer? { get }
}

public extension BotsiProduct {
    var isEligibleForIntroOffer: Bool { false }
    var isEligibleForWinbackOffer: Bool { false }
    var isEligibleForPromotionalOffer: Bool { false }
    
    var introductoryOfferPrice: String? { nil }
    var promotionalOfferPrices: [String] { [] }
    var winbackOfferPrice: String? { nil }
}

// MARK: - SK1
protocol BotsiSK1Product: BotsiProduct {
    var skProduct: SKProduct { get }
}

extension BotsiSK1Product {
    public var sk1Product: SKProduct? { skProduct }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    public var sk2Product: Product? { nil }
    
    var productId: String { skProduct.productIdentifier }
    
    var title: String { skProduct.localizedTitle }
    
    var descriptionText: String { skProduct.localizedDescription }
    
    var price: Decimal { skProduct.price as Decimal }
    
    var currencyCode: String? { skProduct.priceLocale.currencyCode ??
        Locale.current.currencyCode }
    
    var localizedPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        return formatter.string(from: skProduct.price)
    }
    
    var isEligibleForIntroOffer: Bool { skProduct.introductoryPrice != nil }
    
    var introductoryPrice: String? {
        if let introPrice = skProduct.introductoryPrice {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = skProduct.priceLocale
            return formatter.string(from: introPrice.price)
        } else { return nil }
    }
    
    var subscriptionGroupIdentifier: String? { skProduct.subscriptionGroupIdentifier }
    
    var localizedSubscriptionPeriod: String? {
        if let sk1Period = skProduct.subscriptionPeriod?.toCustomPeriod {
            return "\(sk1Period.numberOfUnits) \(sk1Period.unit)"
        } else { return nil }
    }
    
    public var description: String {
        """
        SK1ProductDetails(
          productId: \(productId),
          title: "\(title)",
          descriptionText: "\(descriptionText)",
          price: \(price),
          currencyCode: \(currencyCode ?? "n/a"),
          localizedPrice: \(localizedPrice ?? "n/a"),
          introductoryPrice: \(introductoryPrice ?? "n/a"),
          isEligibleForIntroOffer: \(isEligibleForIntroOffer),
          subscriptionGroupIdentifier: \(subscriptionGroupIdentifier ?? "n/a")
        )
        """
    }
}

extension BotsiSK1Product {
    typealias OfferType = BotsiPaymentTransaction.OfferType
    func isEligible(for offerType: OfferType) -> Bool {
        switch offerType {
        case .introductory:
            return isEligibleForIntroOffer
        case .winBack:
            return isEligibleForWinbackOffer
        case .promotional:
            return isEligibleForPromotionalOffer
        case .code, .unknown:
            return false
        }
    }
}

// MARK: - SK2

@available(iOS 15.0, *)
protocol BotsiSK2Product: BotsiProduct {
    var skProduct: Product { get }
}

@available(iOS 15.0, *)
extension BotsiSK2Product {
    public var sk1Product: SKProduct? { nil }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    public var sk2Product: Product? { skProduct }
    
    var productId: String { skProduct.id }
    
    var title: String { skProduct.displayName }
    
    var descriptionText: String { skProduct.description }
    
    var price: Decimal { skProduct.price }
    
    var currencyCode: String? { skProduct.priceFormatStyle.currencyCode }
    
    var localizedPrice: String? { skProduct.displayPrice }
    
    var isEligibleForIntroOffer: Bool { skProduct.subscription?.introductoryOffer != nil }
    
    var introductoryPrice: String? {
        if let introOffer = skProduct.subscription?.introductoryOffer {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            return formatter.string(from: NSDecimalNumber(decimal: introOffer.price))
        } else {
            return nil
        }
    }
    
    var subscriptionGroupIdentifier: String? {
        if let sub = skProduct.subscription {
            return sub.subscriptionGroupID
        } else { return nil }
    }
    
    var localizedSubscriptionPeriod: String? {
        if let subPeriod = skProduct.subscription?.subscriptionPeriod {
            return "\(subPeriod.value) \(subPeriod.unit)"
        } else { return nil }
    }
    
    public var description: String {
        """
        SK2ProductDetails(
          productId: \(productId),
          title: "\(title)",
          descriptionText: "\(descriptionText)",
          price: \(price),
          currencyCode: \(currencyCode ?? "n/a"),
          localizedPrice: \(localizedPrice ?? "n/a"),
          introductoryPrice: \(introductoryPrice ?? "n/a"),
          isEligibleForIntroOffer: \(isEligibleForIntroOffer),
          subscriptionGroupIdentifier: \(subscriptionGroupIdentifier ?? "n/a")
        )
        """
    }
}

// MARK: - SK Products
struct BotsiSK1PaywallProduct: BotsiSK1Product {
    var skProduct: SKProduct
    var paywallId: Int
    var placementId: String?
    var abTestId: Int?
    
    var subscriptionOffer: BotsiOffer?
}

@available(iOS 15.0, *)
struct BotsiSK2PaywallProduct: BotsiSK2Product {
    var skProduct: Product
    var paywallId: Int
    var placementId: String?
    var abTestId: Int?
    
    var subscriptionOffer: BotsiOffer?
}

@available(iOS 15.0, *)
extension Product {
    func unfWinBackOffer(byId identifier: String) -> Product.SubscriptionOffer? {
        #if compiler(<6.0)
        return nil
        #else
        
        guard #available(iOS 18.0, macOS 15.0, *) else {
            return nil
        }

        return subscription?.winBackOffers.first { $0.id == identifier }
        #endif
    }
    
    var introductoryOfferNotApplicable: Bool {
        subscription?.introductoryOffer == nil
    }
    
    private var unfIntroductoryOffer: Product.SubscriptionOffer? {
        subscription?.introductoryOffer
    }

    private func unfPromotionalOffer(byId identifier: String) -> Product.SubscriptionOffer? {
        subscription?.promotionalOffers.first(where: { $0.id == identifier })
    }
    
    @inlinable
    var unfPeriodLocale: Locale {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return subscriptionPeriodFormatStyle.locale
        }
        return .autoupdatingCurrent
    }
    
    @inlinable
    var unfCurrencyCode: String? {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return priceFormatStyle.currencyCode
        }

        guard let decoded = try? JSONSerialization.jsonObject(with: jsonRepresentation),
              let dict = decoded as? [String: Any],
              let attributes = dict["attributes"] as? [String: Any],
              let offers = attributes["offers"] as? [[String: Any]],
              let code = offers.first?["currencyCode"] as? String
        else {
            return nil
        }

        return code
    }
    
    func subscriptionOffer(by offerIdentifier: BotsiOffer.Identifier) -> BotsiOffer? {
        let offer: Product.SubscriptionOffer? =
            switch offerIdentifier {
            case .introductory:
                unfIntroductoryOffer
            case .promotional(let id):
                unfPromotionalOffer(byId: id)
            case .winBack(let id):
                unfWinBackOffer(byId: id)
            }
        guard let offer else { return nil }

        let period = offer.period
        let periodLocale = unfPeriodLocale
        let subscriptionPeriod = BotsiSubscriptionPeriod(unit: period.unit.toPeriodUnit, numberOfUnits: period.value)
        
        return BotsiOffer(
            price: offer.price,
            currencyCode: unfCurrencyCode,
            localizedPrice: offer.displayPrice,
            offerIdentifier: offerIdentifier,
            subscriptionPeriod: subscriptionPeriod,
            numberOfPeriods: offer.periodCount,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: periodLocale.localized(period: subscriptionPeriod),
            localizedNumberOfPeriods: periodLocale.localized(period: subscriptionPeriod, numberOfPeriods: offer.periodCount)
        )
    }
}
