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
    
    /// `Convenience method for StoreKit 1 transactions.`
    func completeTransaction(with transaction: SKPaymentTransaction, product: SKProduct) async -> BotsiPaymentTransaction {
        return BotsiPaymentTransaction(with: product, transaction: transaction)
    }
    
    /// `Convenience method for StoreKit 2 transactions.`
    @available(iOS 15.0, *)
    func completeTransaction(with transaction: Transaction, product: Product) async -> BotsiPaymentTransaction {
        return BotsiPaymentTransaction(with: product, transaction: transaction)
    }
}

struct BotsiStoreKit1TransactionMapper: BotsiPurchasesManagerConformable { }
struct BotsiStoreKit2TransactionMapper: BotsiPurchasesManagerConformable { }
