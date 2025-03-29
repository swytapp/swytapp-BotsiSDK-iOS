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
        let sortedProducts = sortProducts(products, by: productIDs)
        return sortedProducts
    }
    
    @available(iOS 15.0, *)
    private func sortProducts(_ products: [Product], by identifiers: [String]) -> [Product] {
        var productMap = [String: Product]()
        for product in products {
            productMap[product.id] = product
        }
        return identifiers.compactMap { productMap[$0] }
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
        var processedTransactionIds = Set<UInt64>()
                
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                guard !processedTransactionIds.contains(transaction.id) else {
                    print("Skipping already processed transaction: \(transaction.id)")
                    continue
                }
                
                processedTransactionIds.insert(transaction.id)
                
                let isRenewal = transaction.isRenewal
                do {
                    let products = try await Product.products(for: [transaction.productID])
                    if let product = products.first {
                        let botsiTransaction = await mapper.completeTransaction(with: transaction, product: product)
                        
                        if let _ = await storage.getProfile() {
                            do {
                                let updatedProfile = try await validateTransaction(botsiTransaction)
                                await storage.setProfile(updatedProfile)
                                
                                print("Transaction processed automatically: \(transaction.id)")
                                
                                // For renewals update the user's UI or send a notification ??
                                if isRenewal {
                                    await notifySubscriptionRenewal(product: product, profile: updatedProfile)
                                }
                                
                            } catch let validationError as NSError {
                                if validationError.isRetryableError() {
                                    print("Retryable error encountered: \(validationError.localizedDescription)")
                                    
                                    // Don't finish the transaction so it will be retried next time (to not lose transactions)
                                    processedTransactionIds.remove(transaction.id)
                                    continue
                                } else {
                                    print("Non-retryable validation error: \(validationError.localizedDescription)")
                                }
                            }
                        } else {
                            print("No profile available for transaction validation")
                        }
                    } else {
                        print("Could not fetch product for transaction: \(transaction.id)")
                    }
                    
                    // finish after successful processing
                    await transaction.finish()
                } catch {
                    print("Error processing transaction update: \(error.localizedDescription)")
                    await transaction.finish()
                }
                
            case .unverified(let transaction, let verificationError):
                print("Unverified transaction found. Error: \(verificationError.localizedDescription)")
                
                do {
                    if shouldProceedDespiteVerificationError(verificationError) {
                        let products = try await Product.products(for: [transaction.productID])
                        if let product = products.first {
                            let botsiTransaction = await mapper.completeTransaction(with: transaction, product: product)
                            let updatedProfile = try await validateTransaction(botsiTransaction)
                            await storage.setProfile(updatedProfile)
                        }
                    }
                } catch {
                    print("Error handling unverified transaction: \(error.localizedDescription)")
                }
            
                await transaction.finish()
            }
        }
    }
    
    @available(iOS 15.0, *)
    private func notifySubscriptionRenewal(product: Product, profile: BotsiProfile) async {
        // Post notification for UI updates
        print("Subscription renewed: \(product.displayName)")
    }
    
    @available(iOS 15.0, *)
    private func shouldProceedDespiteVerificationError(_ error: StoreKit.VerificationResult<StoreKit.Transaction>.VerificationError) -> Bool {
        // proceed with the transaction despite verification issues, e.g. test environment
        switch error {
        case .invalidSignature:
            return false
        case .invalidCertificateChain:
            #if DEBUG
            return true
            #else
            return false
            #endif
        default:
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
    
    @discardableResult
    private func validateTransaction(_ transaction: BotsiPaymentTransaction) async throws -> BotsiProfile {
        guard let storedProfile = await storage.getProfile() else {
            throw BotsiError.customError("ValidateTransaction", "Unable to retrieve profile id")
        }
        let repository = ValidateTransactionRepository(httpClient: client, profileId: storedProfile.profileId)
        let profileFetched = try await repository.validateTransaction(transaction: transaction)
        await storage.setProfile(profileFetched)
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
        await storage.setProfile(profileFetched)
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

@available(iOS 15.0, *)
private extension Transaction {
    var isRenewal: Bool {
        // Check if this transaction has a different originalID
        return originalID != id
    }
}

private extension NSError {
    func isRetryableError() -> Bool {
        if domain == NSURLErrorDomain {
            let retryableCodes: [Int] = [
                NSURLErrorTimedOut,
                NSURLErrorCannotConnectToHost,
                NSURLErrorNetworkConnectionLost,
                NSURLErrorNotConnectedToInternet
            ]
            return retryableCodes.contains(code)
        }
        
        if domain == "BotsiHTTPError" && code >= 500 && code < 600 {
            return true
        }
        
        return false
    }
}
