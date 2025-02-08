//
//  Botsi+ReportTransaction.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 06.10.2024
//

import StoreKit

public extension Botsi {
    package nonisolated static func reportTransaction(
        _ transactionId: String,
        withVariationId variationId: String?
    ) async throws -> BotsiProfile {
        try await withActivatedSDK(methodName: .setVariationId, logParams: [
            "variation_id": variationId,
            "transaction_id": transactionId,
        ]) { sdk in

            let profileId = sdk.profileStorage.profileId
            let response = try await sdk.reportTransaction(
                profileId: profileId,
                transactionId: transactionId,
                variationId: variationId
            )
            return response.value
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Botsi SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Botsi Dashboard.
    ///
    /// - Parameters:
    ///   - sk1Transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 1) [SKPaymentTransaction](https://developer.apple.com/documentation/storekit/skpaymenttransaction).
    ///   - withVariationId:  A string identifier of variation. You can get it using variationId property of ``BotsiPaywall``.
    /// - Throws: An ``AdaptyError`` object
    nonisolated static func reportTransaction(
        _ sk1Transaction: SKPaymentTransaction,
        withVariationId variationId: String? = nil
    ) async throws {
        try await withActivatedSDK(methodName: .reportSK1Transaction, logParams: [
            "variation_id": variationId,
            "transaction_id": sk1Transaction.transactionIdentifier,
        ]) { sdk in

            guard sk1Transaction.transactionState == .purchased || sk1Transaction.transactionState == .restored,
                  let id = sk1Transaction.transactionIdentifier
            else {
                throw BotsiError.wrongParamPurchasedTransaction()
            }

            let sk1Transaction = SK1TransactionWithIdentifier(sk1Transaction, id: id)
            let profileId = try await sdk.createdProfileManager.profileId

            let purchasedTransaction =
                if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                    await sdk.productsManager.fillPurchasedTransaction(
                        variationId: variationId,
                        persistentVariationId: nil,
                        sk1Transaction: sk1Transaction
                    )
                } else {
                    await sdk.productsManager.fillPurchasedTransaction(
                        variationId: variationId,
                        persistentVariationId: nil,
                        sk1Transaction: sk1Transaction
                    )
                }

            _ = try await sdk.validatePurchase(
                profileId: profileId,
                transaction: purchasedTransaction,
                reason: .setVariation
            )
        }
    }

    /// Link purchased transaction with paywall's variationId.
    ///
    /// In [Observer mode](https://docs.adapty.io/docs/ios-observer-mode), Botsi SDK doesn't know, where the purchase was made from. If you display products using our [Paywalls](https://docs.adapty.io/docs/paywall) or [A/B Tests](https://docs.adapty.io/docs/ab-test), you can manually assign variation to the purchase. After doing this, you'll be able to see metrics in Botsi Dashboard.
    ///
    /// - Parameters:
    ///   - sk2Transaction: A purchased transaction (note, that this method is suitable only for Store Kit version 2) [Transaction](https://developer.apple.com/documentation/storekit/transaction).
    ///   - withVariationId:  A string identifier of variation. You can get it using variationId property of `BotsiPaywall`.
    /// - Throws: An ``BotsiError`` object
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    nonisolated static func reportTransaction(
        _ sk2Transaction: Transaction,
        withVariationId variationId: String? = nil
    ) async throws {
        try await withActivatedSDK(methodName: .reportSK2Transaction, logParams: [
            "variation_id": variationId,
            "transaction_id": sk2Transaction.unfIdentifier,
        ]) { sdk in
            let profileId = try await sdk.createdProfileManager.profileId

            let purchasedTransaction = await sdk.productsManager.fillPurchasedTransaction(
                variationId: variationId,
                persistentVariationId: nil,
                sk2Transaction: sk2Transaction
            )

            _ = try await sdk.validatePurchase(
                profileId: profileId,
                transaction: purchasedTransaction,
                reason: .setVariation
            )
        }
    }
}
