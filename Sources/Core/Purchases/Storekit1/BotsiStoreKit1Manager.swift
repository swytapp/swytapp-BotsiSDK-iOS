//
//  BotsiStoreKit1Manager.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import StoreKit

// MARK: - StoreKit 1

public actor StoreKit1Handler {
    private var fetchProductCompletion: ((Result<SKProduct, Error>) -> Void)?
    private var fetchProductsCompletion: ((Result<[SKProduct], Error>) -> Void)?
    
    private var purchaseContinuation: CheckedContinuation<BotsiProfile, Error>?
    private var restoreContinuation: CheckedContinuation<BotsiProfile, Error>?

    private var lastRestoredProfile: BotsiProfile?

    private var currentSKProduct: SKProduct?
    
    /// `internal delegate to handle StoreKit callbacks`
    private let delegate = StoreKit1HandlerDelegate()
    
    private let client: BotsiHttpClient
    private let storage: BotsiProfileStorage
    private let mapper: BotsiStoreKit1TransactionMapper = .init()
    private let cachedTransactionStore: BotsiSyncedTransactionStore
    private let configuration: BotsiConfiguration
    private let paywallStorage: BotsiPaywallMappingStorage
    
    private var pendingProducts: [String: BotsiProduct] = [:]
    private var processingTransactions = Set<String>()
    
    public init(
        client: BotsiHttpClient,
        storage: BotsiProfileStorage,
        configuration: BotsiConfiguration,
        cachedTransactionsStore: BotsiSyncedTransactionStore)
    {
        self.client = client
        self.storage = storage
        self.cachedTransactionStore = cachedTransactionsStore
        self.configuration = configuration
        self.paywallStorage = BotsiPaywallMappingStorage()
        delegate.handler = self
    }
    
    public func startObservingTransactions() {
        delegate.handler = self
        SKPaymentQueue.default().add(delegate)
    }
    
    deinit {
        Task.detached { [delegate] in
            delegate.handler = nil
            SKPaymentQueue.default().remove(delegate)
        }
    }
    
    public func retrieveSK1Product(with productID: String) async throws -> SKProduct {
        try await withCheckedThrowingContinuation { continuation in
            self.retrieveProductCallbackVersion(with: productID) { result in
                switch result {
                case .success(let skProduct):
                    continuation.resume(returning: skProduct)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func retrieveSK1Products(from productIds: [String]) async throws -> [SK1ProductDetails] {
        try await withCheckedThrowingContinuation { continuation in
            self.retrieveProductCallbackVersion(with: Set(productIds)) { result in
                switch result {
                case .success(let skProducts):
                    let sorted = self.sortProducts(skProducts, by: productIds)
                    let productDetails = sorted.map { $0.toSK1ProductDetails() }
                    continuation.resume(returning: productDetails)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func retrieveProductCallbackVersion(
            with productID: String,
            completion: @escaping (Result<SKProduct, Error>) -> Void
        ) {
            self.fetchProductCompletion = completion

            let request = SKProductsRequest(productIdentifiers: [productID])
            request.delegate = self.delegate
            request.start()
    }
    
    private func retrieveProductCallbackVersion(
        with productIds: Set<String>,
            completion: @escaping (Result<[SKProduct], Error>) -> Void
        ) {
            self.fetchProductsCompletion = completion

            let request = SKProductsRequest(productIdentifiers: productIds)
            request.delegate = self.delegate
            request.start()
    }
    
    public func purchaseSK1(_ product: BotsiProduct) async throws -> BotsiProfile {
        guard let sk1product = product.sk1Product else {
            throw BotsiError.customError("SK1PurchaseError", "Unable to unwrap SK1 product")
        }
        
        guard purchaseContinuation == nil else {
            throw BotsiError.customError("SK1. Purchase In Progress", "Another purchase is currently being processed.")
        }
       currentSKProduct = sk1product
        
       return try await withCheckedThrowingContinuation { continuation in
           self.purchaseContinuation = continuation

           let payment = SKPayment(product: sk1product)
           self.pendingProducts[payment.productIdentifier] = product
           
           SKPaymentQueue.default().add(payment)
       }
    }
    
    public func restorePurchases() async throws -> BotsiProfile {
        return try await restoreTransactions()
    }
    
    internal func onDidReceiveProductsResponse(_ response: SKProductsResponse) {
        if let completion = fetchProductCompletion {
            
            fetchProductCompletion = nil
            
            guard let product = response.products.first else {
                let error = NSError(
                    domain: "StoreKit1Handler",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "No matching SKProduct found."]
                )
                completion(.failure(error))
                return
            }
            completion(.success(product))
        } else if let completion = fetchProductsCompletion {
            fetchProductsCompletion = nil
            
            let products = response.products
            completion(.success(products))
        } else {
            return
        }
    }

    private func sortProducts(_ products: [SKProduct], by identifiers: [String]) -> [SKProduct] {
        var productMap = [String: SKProduct]()
        for product in products {
            productMap[product.productIdentifier] = product
        }
        return identifiers.compactMap { productMap[$0] }
    }
    
    internal func onDidFailRequest(_ error: Error) {
        if let completion = fetchProductCompletion {
            fetchProductCompletion = nil
            completion(.failure(error))
        } else if let completion = fetchProductsCompletion {
            fetchProductsCompletion = nil
            completion(.failure(error))
        } else { return }
    }
    
    internal func onUpdatedTransactions(_ transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .restored:
                handleRestored(transaction)
            case .failed:
                handleFailed(transaction, source: .failed)
            case .purchasing:
                break
            case .deferred:
                // the transaction is pending approval (e.g., parental controls)
                break
            @unknown default:
                break
            }
        }
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        logTransactionDetails(transaction)
        guard let transactionId = transaction.transactionIdentifier, !processingTransactions.contains(transactionId) else {
            BotsiLog.info("Transaction \(transaction.transactionIdentifier ?? "") already being processed, skipping...")
            return
        }
        
        processingTransactions.insert(transactionId)
        
        let productId = transaction.payment.productIdentifier
        Task {
            defer {
                processingTransactions.remove(transactionId)
                pendingProducts[productId] = nil
                if productId == currentSKProduct?.productIdentifier {
                    currentSKProduct = nil
                }
            }
            
            let product: SKProduct
            let botsiProduct: BotsiProduct? = pendingProducts[productId]
            if let skProduct = botsiProduct?.sk1Product {
                product = skProduct
            } else if let currentProduct = currentSKProduct, currentProduct.productIdentifier == productId {
                product = currentProduct
            } else {
                do {
                    product = try await retrieveSK1Product(with: productId)
                } catch {
                    BotsiLog.error("SK1. handlePurchased. Failed to retrieve product for transaction: \(error.localizedDescription)")
                    handleFailed(transaction, source: .purchase)
                    return
                }
            }
            
            let (current, cached) = await paywallStorage.getPaywallMeta(for: productId)
            let paywallId: Int? = botsiProduct?.paywallId ?? current?.paywallId ?? cached?.paywallId
            let placementId: String? = botsiProduct?.placementId ?? current?.placementId ?? cached?.placementId
            let abTestId: Int? = botsiProduct?.abTestId ?? current?.abTestId ?? cached?.abTestId
            
            let botsiTransaction = await mapper.completeTransaction(
                with: transaction,
                product: product,
                paywallId: paywallId,
                abTestId: abTestId,
                placementId: placementId
            )
            
            do {
                let profile = try await validateTransaction(
                    botsiTransaction,
                    source: .purchasing
                )
                await cachedTransactionStore.saveLastSyncedTransaction(botsiTransaction.originalTransactionId)
                
                if let continuation = purchaseContinuation,
                   product.productIdentifier == currentSKProduct?.productIdentifier {
                    continuation.resume(returning: profile)
                    purchaseContinuation = nil
                }
                
                if restoreContinuation != nil {
                    lastRestoredProfile = profile
                }
            } catch {
                BotsiLog.error("SK1. handlePurchased. Failed to validate transaction: \(error.localizedDescription)")
                handleFailed(transaction, source: .purchase)
            }
            
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    func logTransactionDetails(_ transaction: SKPaymentTransaction) {
        print("==== Transaction Details ====")
        print("identifier: \(transaction.transactionIdentifier ?? "")")
        print("date: \(transaction.transactionDate?.description ?? "")")
        print("state: \(transaction.transactionState)")
        print("payment.productIdentifier: \(transaction.payment.productIdentifier)")
        print("payment.quantity: \(transaction.payment.quantity)")
        
        if let originalTransaction = transaction.original {
            print("originalTransactionIdentifier: \(originalTransaction.transactionIdentifier ?? "")")
            print("originalTransactionDate: \(originalTransaction.transactionDate?.description ?? "")")
        }
        
        if let error = transaction.error as NSError? {
            print("error.code: \(error.code)")
            print("error.domain: \(error.domain)")
            print("error.localizedDescription: \(error.localizedDescription)")
        }
        print("=============================")
    }

    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        #if DEBUG
        logTransactionDetails(transaction)
        #endif
                
        let transactionId = transaction.transactionIdentifier ?? transaction.original?.transactionIdentifier ?? UUID().uuidString
        let productId = transaction.payment.productIdentifier
        
        guard !processingTransactions.contains(transactionId) else { return }
        processingTransactions.insert(transactionId)
        
        Task {
            defer {
                processingTransactions.remove(transactionId)
                if productId == currentSKProduct?.productIdentifier {
                    currentSKProduct = nil
                }
            }
            
            let product: SKProduct
            if let botsiProduct = pendingProducts[productId], let skProduct = botsiProduct.sk1Product {
                product = skProduct
            } else if let currentProduct = currentSKProduct, currentProduct.productIdentifier == productId {
                product = currentProduct
            } else {
                do {
                    product = try await retrieveSK1Product(with: productId)
                } catch {
                    BotsiLog.error("SK1. handleRestored. Failed to retrieve product for transaction: \(error.localizedDescription)")
                    return
                }
            }
            
            let (current, cached) = await paywallStorage.getPaywallMeta(for: productId)
            let paywallId: Int? = current?.paywallId ?? cached?.paywallId
            let placementId: String? = current?.placementId ?? cached?.placementId
            let abTestId: Int? = current?.abTestId ?? cached?.abTestId
            
            let botsiTransaction = await mapper.completeTransaction(
                with: transaction,
                product: product,
                paywallId: paywallId,
                abTestId: abTestId,
                placementId: placementId
            )
            do {
                let profile = try await validateTransaction(
                    botsiTransaction,
                    source: .restore
                )
                await cachedTransactionStore.saveLastSyncedTransaction(botsiTransaction.originalTransactionId)
                
                lastRestoredProfile = profile
            } catch {
                BotsiLog.error("SK1. handleRestored. Failed to restore transaction: \(error.localizedDescription)")
            }
            
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction, source: UpdateTransactionSource) {
        if let error = transaction.error {
            BotsiLog.debug("SK1. handleFailed. Transaction failed with error: \(error.localizedDescription)")
            
            purchaseContinuation?.resume(throwing: error)
            purchaseContinuation = nil
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        currentSKProduct = nil
    }
    
    private func validateTransaction(
        _ transaction: BotsiPaymentTransaction,
        source: StoreKitTransactionSource
    ) async throws -> BotsiProfile {
        guard let storedProfile = await storage.getProfile() else {
            throw BotsiError.customError("ValidateTransaction", "Unable to retrieve profile id")
        }
        let repository = ValidateTransactionRepository(httpClient: client, profileId: storedProfile.profileId)
        let profileFetched = try await repository.validateTransaction(
            transaction: transaction,
            source: source
        )
        BotsiLog.info("Profile received after validating transaction: \(profileFetched.profileId) with access levels: \(profileFetched.accessLevels.first?.key ?? "empty")")
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
    
    public func refreshReceipt() async throws -> Data {
        let helper = ReceiptRefreshHelper()
        let receiptData = try await helper.refreshReceipt()
        return receiptData
    }
    
    internal func onRestoreCompletedTransactionsFinished() {
        if let profile = lastRestoredProfile {
            restoreContinuation?.resume(returning: profile)
        } else {
            let error = BotsiError.customError("Restore", "No restored transactions or no valid profile received.")
            restoreContinuation?.resume(throwing: error)
        }
        
        restoreContinuation = nil
        lastRestoredProfile = nil
    }
}

private class StoreKit1HandlerDelegate: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, @unchecked Sendable {
    weak var handler: StoreKit1Handler?
    
    // MARK: - SKProductsRequestDelegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let handler = handler else { return }
        Task {
            await handler.onDidReceiveProductsResponse(response)
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        guard let handler = handler else { return }
        Task {
            await handler.onDidFailRequest(error)
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard let handler = handler else { return }
        Task {
            await handler.onUpdatedTransactions(transactions)
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        guard let handler = handler else { return }
        Task {
            await handler.onRestoreCompletedTransactionsFinished()
        }
    }
}

extension StoreKit1Handler {
    enum UpdateTransactionSource {
        case purchase
        case restore
        case failed
    }
}
