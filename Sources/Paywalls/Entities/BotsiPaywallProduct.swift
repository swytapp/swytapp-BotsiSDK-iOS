//
//  BotsiPaywallProduct.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import StoreKit

public protocol BotsiPaywallProductWithoutDeterminingOffer: BotsiProduct {

    var botsiProductId: String { get }
    
    /// Same as `variationId` property of the parent BotsiPaywall.
    var variationId: String { get }

    /// Same as `abTestName` property of the parent BotsiPaywall.
    var paywallABTestName: String { get }

    /// Same as `name` property of the parent BotsiPaywall.
    var paywallName: String { get }
}

public protocol BotsiPaywallProduct: BotsiPaywallProductWithoutDeterminingOffer {
    var subscriptionOffer: BotsiSubscriptionOffer? { get }
}

