//
//  BotsiSK1PaywallProduct.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

struct BotsiSK1PaywallProduct: BotsiSK1Product {
    let skProduct: SK1Product

    public let botsiProductId: String

    public let subscriptionOffer: BotsiSubscriptionOffer?

    /// Same as `variationId` property of the parent BotsiPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent BotsiPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent BotsiPaywall.
    public let paywallName: String

    public var description: String {
        "(vendorProductId: \(vendorProductId), paywallName: \(paywallName), botsiProductId: \(botsiProductId), variationId: \(variationId), paywallABTestName: \(paywallABTestName), subscriptionOffer:\(subscriptionOffer.map { $0.description } ?? "nil") , skProduct:\(skProduct)"
    }
}

extension BotsiSK1PaywallProduct: BotsiPaywallProduct {}

struct BotsiSK1PaywallProductWithoutDeterminingOffer: BotsiSK1Product {
    let skProduct: SK1Product

    public let botsiProductId: String

    /// Same as `variationId` property of the parent BotsiPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent BotsiPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent BotsiPaywall.
    public let paywallName: String

    public var description: String {
        "(vendorProductId: \(vendorProductId), paywallName: \(paywallName), botsiProductId: \(botsiProductId), variationId: \(variationId), paywallABTestName: \(paywallABTestName), skProduct:\(skProduct)"
    }
}

extension BotsiSK1PaywallProductWithoutDeterminingOffer: BotsiPaywallProductWithoutDeterminingOffer {}
