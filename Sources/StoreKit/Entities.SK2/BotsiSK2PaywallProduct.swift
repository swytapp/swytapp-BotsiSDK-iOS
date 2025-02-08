//
//  BotsiSK2PaywallProduct.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiSK2PaywallProduct: BotsiSK2Product {
    let skProduct: SK2Product

    
    public let botsiProductId: String

    public let subscriptionOffer: BotsiSubscriptionOffer?

    /// Same as `variationId` property of the parent BotsiPaywall.
    public let variationId: String

    /// Same as `abTestName` property of the parent BotsiPaywall.
    public let paywallABTestName: String

    /// Same as `name` property of the parent BotsiPaywall.
    public let paywallName: String

    public var description: String {
        "(vendorProductId: \(vendorProductId), paywallName: \(paywallName), botsiProductId: \(botsiProductId), variationId: \(variationId), paywallABTestName: \(paywallABTestName), subscriptionOffer:\(subscriptionOffer.map({ $0.description }) ?? "nil") , skProduct:\(skProduct)"
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension BotsiSK2PaywallProduct: BotsiPaywallProduct {}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiSK2PaywallProductWithoutDeterminingOffer: BotsiSK2Product {
    let skProduct: SK2Product

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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension BotsiSK2PaywallProductWithoutDeterminingOffer: BotsiPaywallProductWithoutDeterminingOffer{}
