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

    private var currentSKProduct: SKProduct?
    
    /// Our internal delegate to handle StoreKit callbacks.
    private let delegate = StoreKit1HandlerDelegate()
    
    private let client: BotsiHttpClient
    private let storage: BotsiStorageManager
    private let mapper: BotsiStoreKit1TransactionMapper = .init()
    
    // MARK: - Initialization
    
    public init(client: BotsiHttpClient, storage: BotsiStorageManager) {
        self.client = client
        self.storage = storage
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
    
    /// Initiates a purchase for the given `SKProduct`.
    public func purchaseSK1(_ product: SKProduct) {
        currentSKProduct = product
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
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
                handleFailed(transaction)
            case .purchasing:
                // No special action needed
                break
            case .deferred:
                // The transaction is pending approval (e.g., parental controls)
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
                    try await validateTransaction(botsiTransaction)
                } catch {
                    handleFailed(transaction)
                }
               
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        currentSKProduct = nil
        
        // TODO: Make API call?
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
        // For restoration logic
        SKPaymentQueue.default().finishTransaction(transaction)
        
        currentSKProduct = nil
        // TODO: Restoration callbacks
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error {
            print("Purchase failed: \(error.localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        currentSKProduct = nil
        // TODO: Failure callbacks
    }
    
    private func validateTransaction(_ transaction: BotsiPaymentTransaction) async throws {
        guard let storedProfile = try await storage.retrieve(BotsiProfile.self, forKey: UserDefaultKeys.User.userProfile) else {
            throw BotsiError.customError("ValidateTransaction", "Unable to retrieve profile id")
        }
        let repository = ValidateTransactionRepository(httpClient: client, profileId: storedProfile.profileId)
        let profileFetched = try await repository.validateTransaction(transaction: transaction)
        print("Profile received: \(profileFetched.profileId) with access levels: \(profileFetched.accessLevels.first?.key ?? "empty")")
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
}
