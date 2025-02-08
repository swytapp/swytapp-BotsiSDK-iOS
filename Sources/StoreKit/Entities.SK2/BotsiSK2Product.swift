//
//  BotsiSK2Product.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 16.09.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
protocol BotsiSK2Product: BotsiProduct {
    var skProduct: SK2Product { get }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension BotsiSK2Product {
    public var sk1Product: SK1Product? { nil }

    public var sk2Product: SK2Product? { skProduct }

    public var vendorProductId: String { skProduct.id }

    public var localizedDescription: String { skProduct.description }

    public var localizedTitle: String { skProduct.displayName }

    public var price: Decimal { skProduct.price }

    public var currencyCode: String? { skProduct.unfCurrencyCode }

    public var currencySymbol: String? { skProduct.unfPriceLocale.currencySymbol }

    public var regionCode: String? { skProduct.unfPriceLocale.unfRegionCode }

    public var isFamilyShareable: Bool { skProduct.isFamilyShareable }

    public var subscriptionPeriod: BotsiSubscriptionPeriod? {
        skProduct.subscription?.subscriptionPeriod.asBotsiSubscriptionPeriod
    }

    public var subscriptionGroupIdentifier: String? { skProduct.subscription?.subscriptionGroupID }

    public var localizedPrice: String? { skProduct.displayPrice }

    public var localizedSubscriptionPeriod: String? {
        guard let period = subscriptionPeriod else { return nil }
        return skProduct.unfPeriodLocale.localized(period: period)
    }

    public var description: String {
        "(vendorProductId: \(vendorProductId), skProduct: \(skProduct))"
    }
}
