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
    private let paywallStorage: BotsiPaywallMappingStorage
    
    public init(client: BotsiHttpClient, storage: BotsiProfileStorage) {
        self.client = client
        self.storage = storage
        self.paywallStorage = BotsiPaywallMappingStorage()
        Task {
            if #available(iOS 15.0, *) {
                await self.startObservingTransactionUpdates()
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
                userInfo: [
                    NSLocalizedDescriptionKey: "No matching StoreKit2 Product found."
                ]
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
    public func purchaseSK2(_ product: BotsiProduct) async throws -> BotsiProfile {
        guard let skProduct = product.sk2Product else {
            throw BotsiError.customError("SK2PurchaseError", "Unable to unwrap SK2 Product")
        }
        let result = try await skProduct.purchase()
        
        switch result {
        case .success(let verification):
            switch verification {
            case .unverified(_,_):
                BotsiLog.info("StoreKit 2. Transaction unverified.")
                throw BotsiError.transactionFailed
            case .verified(let transaction):
                let botsiTransaction = await mapper.completeTransaction(
                    with: transaction,
                    product: skProduct,
                    paywallId: product.paywallId,
                    abTestId: product.abTestId
                )
                let profile = try await validateTransaction(
                    botsiTransaction,
                    source: .purchasing
                )
                await paywallStorage.setPaywall(
                    product.paywallId,
                    for: skProduct.id
                )
                await transaction.finish()
                return profile
            }
        case .userCancelled:
            BotsiLog.info("StoreKit 2. User cancelled the purchase.")
            throw BotsiError.transactionFailed
        case .pending:
            throw BotsiError.transactionDeferred
        @unknown default:
            BotsiLog.error("StoreKit 2. Unknown result.")
            throw BotsiError.transactionFailed
        }
    }
    
    @available(iOS 15.0, *)
    private func startObservingTransactionUpdates() async {
        var processedTransactionIds = Set<UInt64>()
                
        for await result in Transaction.updates {
            switch result {
            case .verified(let transaction):
                guard !processedTransactionIds.contains(transaction.id) else {
                    BotsiLog.debug("Skipping already processed transaction: \(transaction.id)")
                    continue
                }
                
                processedTransactionIds.insert(transaction.id)
                
                let isRenewal = transaction.isRenewal
                do {
                    let productId = transaction.productID
                    guard let product = try await Product.products(for: [productId]).first else {
                        throw BotsiError.customError("StoreKit2Handler", "Unable to fetch product with id: \(productId)")
                    }
                    let (current, cached) = await paywallStorage.getPaywallIds(for: productId)
                    let botsiTransaction = await mapper.completeTransaction(
                        with: transaction,
                        product: product,
                        paywallId: current ?? cached ?? nil,
                        abTestId: nil
                    )
              
                    let updatedProfile = try await validateTransaction(
                        botsiTransaction,
                        source: .observing
                    )
                    await storage.setProfile(updatedProfile)
                    
                    BotsiLog.info("StoreKit 2. Transaction \(transaction.id) processed.")
                    
                    if isRenewal {
                        BotsiLog.info("StoreKit 2. Transaction \(transaction.id) renewal.")
                        await notifySubscriptionRenewal(product: product, profile: updatedProfile)
                    }
                        
                    await transaction.finish()
                } catch {
                    if let botsiError = error as? BotsiError {
                        BotsiLog.error("StoreKit 2 Error: \(botsiError.localizedDescription)")
                    } else {
                        let validationError = error as NSError
                        if validationError.isRetryableError() {
                            BotsiLog.error("StoreKit 2 Retrayable error: \(validationError.localizedDescription)")
                            
                            // Don't finish the transaction so it will be retried next time (to not lose transactions)
                            processedTransactionIds.remove(transaction.id)
                            continue
                        } else {
                            BotsiLog.error("StoreKi 2 Validation error: \(validationError.localizedDescription)")
                        }
                    }
            
                    await transaction.finish()
                }
                
            case .unverified(let transaction, let verificationError):
                BotsiLog.debug("StoreKit 2. Unverified transaction found. Error: \(verificationError.localizedDescription)")
                await transaction.finish()
            }
        }
    }
    
    // post notification to UI update
    @available(iOS 15.0, *)
    private func notifySubscriptionRenewal(product: Product, profile: BotsiProfile) async {}
    
    @discardableResult
    private func validateTransaction(_ transaction: BotsiPaymentTransaction, source: StoreKitTransactionSource) async throws -> BotsiProfile {
        guard let storedProfile = await storage.getProfile() else {
            throw BotsiError.customError("SK2.ValidateTransaction", "Unable to retrieve profile id")
        }
        let repository = ValidateTransactionRepository(
            httpClient: client,
            profileId: storedProfile.profileId
        )
        let profileFetched = try await repository.validateTransaction(
            transaction: transaction,
            source: source
        )
        await storage.setProfile(profileFetched)
        BotsiLog.info("StoreKit 2 Validate. Profile \(profileFetched.profileId) with access levels received: \(profileFetched.accessLevels.first?.key ?? "none")")
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
        BotsiLog.info("StoreKit 2 Restore. Profile received after restoring transaction: \(profileFetched.profileId) with access levels: \(profileFetched.accessLevels.first?.key ?? "none")")
        return profileFetched
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

enum StoreKitTransactionSource: String {
    case purchasing
    case observing
    case restore
}
