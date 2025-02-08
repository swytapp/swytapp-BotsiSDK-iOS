//
//  Botsi+MakePurchase.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import StoreKit

extension Botsi {
    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``BotsiPaywallProduct`` object retrieved from the paywall.
    /// - Returns: The ``BotsiPurchaseResult`` object.
    /// - Throws: An ``BotsiError`` object
    @available(visionOS, unavailable)
    public nonisolated static func makePurchase(product: BotsiPaywallProduct) async throws -> BotsiPurchaseResult {
        try await withActivatedSDK(
            methodName: .makePurchase,
            logParams: [
                "paywall_name": product.paywallName,
                "variation_id": product.variationId,
                "product_id": product.vendorProductId,
            ]
        ) { sdk in

            guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) else {
                guard let manager = sdk.sk1QueueManager else { throw BotsiError.cantMakePayments() }

                return try await manager.makePurchase(
                    profileId: sdk.profileStorage.profileId,
                    product: product
                )
            }

            guard let manager = sdk.sk2Purchaser else { throw BotsiError.cantMakePayments() }

            
            return try await manager.makePurchase(
                profileId: sdk.profileStorage.profileId,
                product: product
            )
        }
    }

    /// To make the purchase, you have to call this method.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases)
    ///
    /// - Parameters:
    ///   - product: a ``BotsiDeferredProduct`` object retrieved from the delegate.
    /// - Returns: The ``BotsiPurchaseResult`` object.
    /// - Throws: An ``BotsiError`` object
    public nonisolated static func makePurchase(product: BotsiDeferredProduct) async throws -> BotsiPurchaseResult {
        try await withActivatedSDK(
            methodName: .makePurchase,
            logParams: [
                "product_id": product.vendorProductId,
            ]
        ) { sdk in
            guard let manager = sdk.sk1QueueManager else { throw BotsiError.cantMakePayments() }
            return try await manager.makePurchase(product: product)
        }
    }

    /// To restore purchases, you have to call this method.
    ///
    /// Read more on the [Botsi Documentation](https://docs.adapty.io/v2.0.0/docs/ios-making-purchases#restoring-purchases)
    ///
    /// - Returns: The ``BotsiProfile`` object. This model contains info about access levels, subscriptions, and non-subscription purchases. Generally, you have to check only access level status to determine whether the user has premium access to the app.
    /// - Throws: An ``BotsiError`` object
    public nonisolated static func restorePurchases() async throws -> BotsiProfile {
        try await withActivatedSDK(methodName: .restorePurchases) { sdk in
            let profileId = sdk.profileStorage.profileId
            if let response = try await sdk.transactionManager.syncTransactions(for: profileId) {
                return response.value
            }

            let manager = try await sdk.createdProfileManager
            if manager.profileId != profileId {
                throw BotsiError.profileWasChanged()
            }

            return await manager.getProfile()
        }
    }
}
