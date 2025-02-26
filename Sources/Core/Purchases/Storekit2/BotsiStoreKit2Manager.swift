//
//  BotsiStoreKit2Manager.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import StoreKit

@available(iOS 15.0, *)
public actor StoreKit2Handler: PurchasingHandler {
    
    private let client: BotsiHttpClient
    private let mapper: BotsiStoreKit2TransactionMapper = .init()
    
    public init(client: BotsiHttpClient) {
        self.client = client
    }
    
    // MARK: - PurchasingHandler Requirements
    nonisolated public func retrieveProduct(
        with productID: String,
        completion: @escaping (Result<SKProduct, Error>) -> Void
    ) {
        completion(.failure(NSError(
            domain: "StoreKit2Handler",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "retrieveProduct(completion:) unavailable in StoreKit2Handler."]
        )))
    }
    
    public func retrieveProductAsync(with productIDs: [String]) async throws -> [Product] {
        let products = try await Product.products(for: productIDs)
        guard let product = products.first else {
            throw NSError(
                domain: "StoreKit2Handler",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "No matching StoreKit2 Product found."]
            )
        }
        return products
    }
    
    nonisolated public func purchaseSK1(_ skProduct: SKProduct) { }
    
    public func purchaseSK2(_ product: Product) async throws -> BotsiPaymentTransaction {
        let result = try await product.purchase() // add for await verification in Transaction.updates { listener
        
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
                return botsiTransaction
            }
        case .userCancelled:
            print("User canceled the purchase.")
            throw BotsiError.transactionFailed
            
        case .pending:
            print("Purchase pending.")
            throw BotsiError.transactionFailed
           
        @unknown default:
            print("Unknown result from StoreKit2.")
            throw BotsiError.transactionFailed
            
        }
    }
}
