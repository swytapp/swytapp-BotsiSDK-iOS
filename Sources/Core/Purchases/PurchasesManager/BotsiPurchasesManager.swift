//
//  BotsiPurchasesManager.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import StoreKit
import Foundation

protocol BotsiPurchasesManagerConformable: Sendable { }

extension BotsiPurchasesManagerConformable {
    
    func completeTransaction(
        with transaction: SKPaymentTransaction,
        product: SKProduct,
        paywallId: Int?,
        abTestId: Int?,
        placementId: String? = nil
    ) async -> BotsiPaymentTransaction {
        return BotsiPaymentTransaction(
            with: product,
            transaction: transaction,
            paywallId: paywallId,
            abTestId: abTestId,
            placementId: placementId
        )
    }
    
    @available(iOS 15.0, *)
    func completeTransaction(
        with transaction: Transaction,
        product: Product,
        paywallId: Int?,
        abTestId: Int?,
        placementId: String? = nil
    ) async -> BotsiPaymentTransaction {
        return BotsiPaymentTransaction(
            with: product,
            transaction: transaction,
            paywallId: paywallId,
            abTestId: abTestId,
            placementId: placementId
        )
    }
}

struct BotsiStoreKit1TransactionMapper: BotsiPurchasesManagerConformable { }
struct BotsiStoreKit2TransactionMapper: BotsiPurchasesManagerConformable { }
