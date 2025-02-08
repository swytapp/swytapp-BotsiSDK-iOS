//
//  Botsi+PaywallProducts.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

public extension Botsi {
    /// Once you have a ``BotsiPaywall``, fetch corresponding products array using this method.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/displaying-products)
    ///
    /// - Parameters:
    ///   - paywall: the ``BotsiPaywall`` for which you want to get a products
    /// - Returns: A result containing the ``BotsiPaywallProduct`` objects array. The order will be the same as in the paywalls object. You can present them in your UI
    /// - Throws: An ``BotsiError`` object
    nonisolated static func getPaywallProducts(paywall: BotsiPaywall) async throws -> [BotsiPaywallProduct] {
        try await withActivatedSDK(
            methodName: .getPaywallProducts,
            logParams: ["placement_id": paywall.placementId]
        ) { sdk in
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                if let manager = sdk.productsManager as? SK2ProductsManager {
                    return try await sdk.getSK2PaywallProducts(
                        paywall: paywall,
                        productsManager: manager
                    )
                }
            } else {
                if let manager = sdk.productsManager as? SK1ProductsManager {
                    return try await sdk.getSK1PaywallProducts(
                        paywall: paywall,
                        productsManager: manager
                    )
                }
            }
            return []
        }
    }

    nonisolated static func getPaywallProductsWithoutDeterminingOffer(paywall: BotsiPaywall) async throws -> [BotsiPaywallProductWithoutDeterminingOffer] {
        try await withActivatedSDK(
            methodName: .getPaywallProductswithoutDeterminingOffer,
            logParams: ["placement_id": paywall.placementId]
        ) { sdk in
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                if let manager = sdk.productsManager as? SK2ProductsManager {
                    return try await sdk.getSK2PaywallProductsWithoutOffers(
                        paywall: paywall,
                        productsManager: manager
                    )
                }
            } else {
                if let manager = sdk.productsManager as? SK1ProductsManager {
                    return try await sdk.getSK1PaywallProductsWithoutOffers(
                        paywall: paywall,
                        productsManager: manager
                    )
                }
            }
            return []
        }
    }

    package nonisolated static func getPaywallProduct(
        vendorProductId: String,
        botsiProductId: String,
        subscriptionOfferIdentifier: BotsiSubscriptionOffer.Identifier?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String
    ) async throws -> BotsiPaywallProduct {
        let sdk = try await Botsi.activatedSDK

        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            guard let manager = sdk.productsManager as? SK2ProductsManager else {
                throw BotsiError.cantMakePayments()
            }
            return try await sdk.getSK2PaywallProduct(
                vendorProductId: vendorProductId,
                botsiProductId: botsiProductId,
                subscriptionOfferIdentifier: subscriptionOfferIdentifier,
                variationId: variationId,
                paywallABTestName: paywallABTestName,
                paywallName: paywallName,
                productsManager: manager
            )

        } else {
            guard let manager = sdk.productsManager as? SK1ProductsManager else {
                throw BotsiError.cantMakePayments()
            }
            return try await sdk.getSK1PaywallProduct(
                vendorProductId: vendorProductId,
                botsiProductId: botsiProductId,
                subscriptionOfferIdentifier: subscriptionOfferIdentifier,
                variationId: variationId,
                paywallABTestName: paywallABTestName,
                paywallName: paywallName,
                productsManager: manager
            )
        }
    }
}
