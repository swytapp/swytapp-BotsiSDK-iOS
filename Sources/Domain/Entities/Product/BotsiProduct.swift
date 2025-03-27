//
//  BotsiProduct.swift
//  Botsi
//
//  Created by Vladyslav on 23.03.2025.
//

import StoreKit

public protocol BotsiProduct: Sendable, CustomStringConvertible {
    
    var sk1Product: SKProduct? { get}
    
    @available(iOS 15.0, macOS 12.0, *)
    var sk2Product: Product? { get }
    
    // MARK: - Identifiers
    var productId: String { get }
    
    // MARK: - Display Information
    var title: String { get }
    var descriptionText: String { get }
    
    // MARK: - Pricing
    var price: Decimal { get }
    var currencyCode: String? { get }
    var localizedPrice: String? { get }
    
    // MARK: - Introductory Offers
    var isEligibleForIntroOffer: Bool { get }
    var introductoryPrice: String? { get }
    
    // MARK: - Subscription Details
    
    var subscriptionGroupIdentifier: String? { get }
    var localizedSubscriptionPeriod: String? { get }
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
    
    var price: Decimal { Decimal(string: skProduct.displayPrice) ?? 0 }
    
    var currencyCode: String? { skProduct.priceFormatStyle.currencyCode }
    
    var localizedPrice: String? { skProduct.displayPrice }
    
    var isEligibleForIntroOffer: Bool { skProduct.subscription?.introductoryOffer != nil }
    
    var introductoryPrice: String? {
        if let introOffer = skProduct.subscription?.introductoryOffer {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            // let currencyId = skProduct.priceFormatStyle.currencyCode
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
}

@available(iOS 15.0, *)
struct BotsiSK2PaywallProduct: BotsiSK2Product {
    var skProduct: Product
}
