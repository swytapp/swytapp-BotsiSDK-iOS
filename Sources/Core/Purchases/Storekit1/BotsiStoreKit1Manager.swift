//
//  BotsiStoreKit1Manager.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import StoreKit

/// `A unified protocol for both StoreKit1 and StoreKit2 handlers.`
public protocol PurchasingHandler: AnyObject {
    func retrieveProduct(
        with productID: String,
        completion: @escaping (Result<SKProduct, Error>) -> Void
    )
    
    @available(iOS 15.0, *)
    func retrieveProductAsync(with productIDs: [String]) async throws -> [Product]

    func purchaseSK1(_ skProduct: SKProduct)
    
    @available(iOS 15.0, *)
    func purchaseSK2(_ product: Product) async throws -> BotsiPaymentTransaction
}

// MARK: - StoreKit 1
public actor StoreKit1Handler {
    // MARK: - Private State
    
    /// A completion to be invoked when `retrieveProduct` finishes.
    private var fetchCompletion: ((Result<SKProduct, Error>) -> Void)?
    
    private var purchaseContinuation: CheckedContinuation<BotsiProfile, Error>?
    private var restoreContinuation: CheckedContinuation<BotsiProfile, Error>?

    /// `if multiple transactions are restored, store the latest profile`
    private var lastRestoredProfile: BotsiProfile?

    private var currentSKProduct: SKProduct?
    
    /// `internal delegate to handle StoreKit callbacks`
    private let delegate = StoreKit1HandlerDelegate()
    
    private let client: BotsiHttpClient
    private let storage: BotsiProfileStorage
    private let mapper: BotsiStoreKit1TransactionMapper = .init()
    private let cachedTransactionStore: BotsiSyncedTransactionStore
    private let configuration: BotsiConfiguration
    
    // MARK: - Initialization
    
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
        delegate.handler = self
    }
    
    public func startObservingTransactions() {
        delegate.handler = self
        SKPaymentQueue.default().add(delegate)
    }
    
    deinit {
        // end observing
    }
    
    // MARK: - Public Methods
    
    /// `Requests an `SKProduct` for the given product identifier.`
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
    
    private func retrieveProductCallbackVersion(
            with productID: String,
            completion: @escaping (Result<SKProduct, Error>) -> Void
        ) {
            self.fetchCompletion = completion

            let request = SKProductsRequest(productIdentifiers: [productID])
            request.delegate = self.delegate // the internal delegate that you forward to
            request.start()
    }
    
    public func purchaseSK1(_ product: SKProduct) async throws -> BotsiProfile {
        currentSKProduct = product
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        guard purchaseContinuation == nil else {
               throw BotsiError.customError("Purchase In Progress", "Another purchase is currently being processed.")
           }
       currentSKProduct = product
        
       return try await withCheckedThrowingContinuation { continuation in
           self.purchaseContinuation = continuation

           let payment = SKPayment(product: product)
           SKPaymentQueue.default().add(payment)
       }
    }
    
    /// `Restore`
    public func restorePurchases() async throws -> BotsiProfile {
        guard restoreContinuation == nil else {
            throw BotsiError.customError("Restore In Progress", "Another restore is currently happening.")
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.restoreContinuation = continuation
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    // MARK: - Internal Actor Methods (Called by Delegate)
    
    /// `Called from the delegate when products are received.`
    internal func onDidReceiveProductsResponse(_ response: SKProductsResponse) {
        guard let completion = fetchCompletion else { return }
        fetchCompletion = nil
        
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
    }
    
    /// `Called from the delegate when the request fails.`
    internal func onDidFailRequest(_ error: Error) {
        guard let completion = fetchCompletion else { return }
        fetchCompletion = nil
        completion(.failure(error))
    }
    
    /// `Called from the delegate whenever transactions are updated (purchased, restored, failed, etc.).`
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
                // log if needed, no actions for now
                break
            case .deferred:
                // the transaction is pending approval (e.g., parental controls)
                break
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - Transaction Helpers
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        logTransactionDetails(transaction)
        if let purchasedProduct = currentSKProduct {
            Task {
                let botsiTransaction = await mapper.completeTransaction(with: transaction, product: purchasedProduct)
                do {
                    let profile = try await validateTransaction(botsiTransaction)
                    await cachedTransactionStore.saveLastSyncedTransaction(botsiTransaction.originalTransactionId)
                    
                    purchaseContinuation?.resume(returning: profile)
                    purchaseContinuation = nil
                } catch {
                    handleFailed(transaction, source: .purchase)
                }
               
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        currentSKProduct = nil
    }
    
    func logTransactionDetails(_ transaction: SKPaymentTransaction) {
        print("==== Transaction Details ====")
        print("transactionIdentifier: \(transaction.transactionIdentifier ?? "nil")")
        print("transactionDate: \(transaction.transactionDate?.description ?? "nil")")
        print("transactionState: \(transaction.transactionState)")
        print("payment.productIdentifier: \(transaction.payment.productIdentifier)")
        print("payment.quantity: \(transaction.payment.quantity)")
        
        if let originalTransaction = transaction.original {
            print("originalTransactionIdentifier: \(originalTransaction.transactionIdentifier ?? "nil")")
            print("originalTransactionDate: \(originalTransaction.transactionDate?.description ?? "nil")")
        }
        
        if let error = transaction.error as NSError? {
            print("error.code: \(error.code)")
            print("error.domain: \(error.domain)")
            print("error.localizedDescription: \(error.localizedDescription)")
        }
        print("=============================")
    }

    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        if let purchasedProduct = currentSKProduct {
            Task {
                let botsiTransaction = await mapper.completeTransaction(with: transaction, product: purchasedProduct)
                do {
                    let profile = try await restoreTransaction(botsiTransaction)
                    await cachedTransactionStore.saveLastSyncedTransaction(botsiTransaction.originalTransactionId)
                    
                    lastRestoredProfile = profile
                } catch {
                    handleFailed(transaction, source: .restore)
                    
                }
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        currentSKProduct = nil
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction, source: UpdateTransactionSource) {
        if let error = transaction.error {
            print("Purchase failed: \(error.localizedDescription)")
            
            purchaseContinuation?.resume(throwing: error)
            purchaseContinuation = nil
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        currentSKProduct = nil
    }
    
    private func validateTransaction(_ transaction: BotsiPaymentTransaction) async throws -> BotsiProfile {
        guard let storedProfile = await storage.getProfile() else {
            throw BotsiError.customError("ValidateTransaction", "Unable to retrieve profile id")
        }
        let repository = ValidateTransactionRepository(httpClient: client, profileId: storedProfile.profileId)
        let profileFetched = try await repository.validateTransaction(transaction: transaction)
        BotsiLog.info("Profile received after validating transaction: \(profileFetched.profileId) with access levels: \(profileFetched.accessLevels.first?.key ?? "empty")")
        return profileFetched
    }
    
    private func restoreTransaction(_ transaction: BotsiPaymentTransaction) async throws -> BotsiProfile {
        guard let storedProfile = await storage.getProfile() else {
            throw BotsiError.customError("Restore transaction", "Unable to retrieve profile id")
        }
        let repository = RestorePurchaseRepository(httpClient: client, profileId: storedProfile.profileId, configuration: configuration)
        let profileFetched = try await repository.restore(transaction: transaction)
        BotsiLog.info("Profile received after restoring transaction: \(profileFetched.profileId) with access levels: \(profileFetched.accessLevels.first?.key ?? "empty")")
        return profileFetched
    }
    
    func refreshReceipt() async throws -> Data {
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

private class StoreKit1HandlerDelegate: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
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
