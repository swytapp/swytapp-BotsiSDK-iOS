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
    
    public func retrieveProductAsync(with productID: String) async throws -> Product {
        let products = try await Product.products(for: [productID])
        guard let product = products.first else {
            throw NSError(
                domain: "StoreKit2Handler",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "No matching StoreKit2 Product found."]
            )
        }
        return product
    }
    
    nonisolated public func purchaseSK1(_ skProduct: SKProduct) { }
    
    public func purchaseSK2(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .unverified(_,_):
                print("TRANSACTION_UNVERIFIED")
            case .verified(let transaction):
                let transaction = await mapper.completeTransaction(with: transaction, product: product)
                print("TRANSACTION_DATA: \(transaction)")
                //
            }
            
            // Handle successful purchase and verification
            // verification will be a Transaction type that requires verifying
            print("Purchased successfully: \(verification)")
        case .userCancelled:
            print("User canceled the purchase.")
        case .pending:
            print("Purchase pending.")
        @unknown default:
            print("Unknown result from StoreKit2.")
        }
    }
}
