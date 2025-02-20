//
//  BotsiStoreKit1Manager.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import StoreKit
import Foundation


@BotsiActor
struct PurchasesStorekitVersionOne: BotsiPurchasesManagerConformable {
    func completeTransaction(with transaction: SKPaymentTransaction) async -> BotsiPaymentTransaction {
        await BotsiPaymentTransaction(transactionId: <#T##String#>, originalTransactionId: <#T##String#>, vendorProductId: <#T##String#>, productVariationId: <#T##String?#>, persistentProductVariationId: <#T##String?#>, price: <#T##Decimal?#>, priceLocale: <#T##String?#>, storeCountry: <#T##String?#>, subscriptionOffer: <#T##BotsiSubscriptionOffer?#>, environment: <#T##String?#>)
    }
    
    @available(iOS 15, *)
    func completeTransaction(with transaction: Transaction) async -> BotsiPaymentTransaction {
        <#code#>
    }
    
    
}
