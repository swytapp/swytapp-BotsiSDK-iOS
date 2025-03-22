//
//  BotsiStoreKit2Manager.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import StoreKit

public actor StoreKit2Handler {
    
    private let client: BotsiHttpClient
    private let storage: BotsiProfileStorage
    private let mapper: BotsiStoreKit2TransactionMapper = .init()
    
    public init(client: BotsiHttpClient, storage: BotsiProfileStorage) {
        self.client = client
        self.storage = storage
        Task {
            if #available(iOS 15.0, *) {
                await self.startObservingTransactionUpdates()
                // add refersh receipt request
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
    public func purchaseSK2(_ product: Product) async throws -> BotsiProfile {
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
                let profile = try await validateTransaction(botsiTransaction)
                await transaction.finish()
                return profile
            }
        case .userCancelled:
            print("User canceled the purchase.")
            throw BotsiError.transactionFailed
        case .pending:
            print("Purchase pending.")
            let botsiTransaction = try await waitForTransactionUpdate(product)
            let profile = try await validateTransaction(botsiTransaction)
            print("processing transaction")
            return profile
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
                await verifiedTransaction.finish()
                return botsiTransaction
            case .unverified(let unverifiedTransaction, _):
                print("Unverified transaction found. Ignoring.")
                await unverifiedTransaction.finish()
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
    
    private func validateTransaction(_ transaction: BotsiPaymentTransaction) async throws -> BotsiProfile {
        guard let storedProfile = await storage.getProfile() else {
            throw BotsiError.customError("ValidateTransaction", "Unable to retrieve profile id")
        }
        let repository = ValidateTransactionRepository(httpClient: client, profileId: storedProfile.profileId)
        let profileFetched = try await repository.validateTransaction(transaction: transaction)
        print("Profile received: \(profileFetched.profileId) with access levels: \(profileFetched.accessLevels.first?.key ?? "empty")")
        return profileFetched
    }
    
    private func restoreTransactions() async throws -> BotsiProfile {
        guard let storedProfile = await storage.getProfile() else {
            throw BotsiError.customError("Restore transaction", "Unable to retrieve profile id")
        }
        let repository = RestorePurchaseRepository(httpClient: client, profileId: storedProfile.profileId)
        let helper = ReceiptRefreshHelper()
        let receiptData = try await helper.refreshReceipt()
        let profileFetched = try await repository.restore(receipt: receiptData)
        BotsiLog.info("Profile received after restoring transaction: \(profileFetched.profileId) with access levels: \(profileFetched.accessLevels.first?.key ?? "empty")")
        return profileFetched
    }
    
    private func fetchTransactions() async throws {
        if #available(iOS 15.0, *) {
            _ = await Transaction.currentEntitlements.compactMap { $0.debugDescription }.reduce([], +).count
        } else {
            // Fallback on earlier versions
        }
    }

    @available(iOS 15.0, *)
    public func restorePurchases() async throws -> BotsiProfile {
        return try await restoreTransactions()
    }
    
    public func refreshReceipt() async throws -> Data {
        let helper = ReceiptRefreshHelper()
        let receiptData = try await helper.refreshReceipt()
        return receiptData
    }
}
