//
//  BotsiStoreKit2Manager.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import StoreKit

public actor StoreKit2Handler {
    
    private let client: BotsiHttpClient
    private let mapper: BotsiStoreKit2TransactionMapper = .init()
    
    public init(client: BotsiHttpClient) {
        self.client = client
        Task {
            if #available(iOS 15.0, *) {
                await self.startObservingTransactionUpdates()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @available(iOS 15.0, *)
    public func retrieveProductAsync(with productIDs: [String]) async throws -> [Product] {
        let products = try await Product.products(for: productIDs)
        guard let _ = products.first else {
            throw NSError(
                domain: "StoreKit2Handler",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "No matching StoreKit2 Product found."]
            )
        }
        return products
    }
    
    @available(iOS 15.0, *)
    public func purchaseSK2(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .unverified(_,_):
                print("TRANSACTION_UNVERIFIED")
                throw BotsiError.transactionFailed
            case .verified(let transaction):
                let botsiTransaction = await mapper.completeTransaction(with: transaction, product: product)
                print("TRANSACTION_DATA: \(botsiTransaction)")
                await transaction.finish()
            }
        case .userCancelled:
            print("User canceled the purchase.")
            throw BotsiError.transactionFailed
        case .pending:
            print("Purchase pending.")
            let transaction = try await waitForTransactionUpdate(product)
            print("processing transaction")
        @unknown default:
            print("Unknown result from StoreKit2.")
            throw BotsiError.transactionFailed
        }
    }
    
    @available(iOS 15.0, *)
    private func waitForTransactionUpdate(_ product: Product) async throws -> BotsiPaymentTransaction {
        for await transaction in Transaction.updates {
            switch transaction {
            case .verified(let verifiedTransaction):
                let botsiTransaction = await mapper.completeTransaction(with: verifiedTransaction, product: product)
                print("TRANSACTION_UPDATE: \(botsiTransaction)")
                await verifiedTransaction.finish()
                return botsiTransaction
            case .unverified(_, _):
                print("Unverified transaction found. Ignoring.")
                throw BotsiError.customError("Storekit2", "Unverified transaction")
            }
        }
        throw BotsiError.customError("Storekit2", "No updates for a transaction found")
    }
    
    @available(iOS 15.0, *)
    private func startObservingTransactionUpdates() async {
        for await transaction in Transaction.updates {
            switch transaction {
            case .verified(let verifiedTransaction):
                /// `1. while observing we need to construct a BotsiPayment transaction based on verifiedTransaction.productID`
                /// `2.next step is to validate the transaction on the backend if the processing was delayed`
                // let botsiTransaction = await mapper.completeTransaction(with: verifiedTransaction, product: product)
                
                print("TRANSACTION_UPDATE")
                await verifiedTransaction.finish()
            case .unverified(_, _):
                print("Unverified transaction found. Ignoring.")
            }
        }
    }
}
