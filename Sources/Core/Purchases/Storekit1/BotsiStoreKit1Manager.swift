//
//  BotsiStoreKit1Manager.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import StoreKit

// MARK: - StoreKit 1

public actor StoreKit1Handler {
    private var purchaseContinuation: CheckedContinuation<BotsiProfile, Error>?
    private var restoreContinuation: CheckedContinuation<BotsiProfile, Error>?

    private var lastRestoredProfile: BotsiProfile?

    private var currentSKProduct: SKProduct?
    private var productContinuations: [SKProductsRequest: CheckedContinuation<SKProduct, Error>] = [:]
    private var productsContinuations: [SKProductsRequest: CheckedContinuation<[SKProduct], Error>] = [:]
    
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
        
        processPendingTransactions()
    }
    
    private func processPendingTransactions() {
        let pending = SKPaymentQueue.default().transactions
        if !pending.isEmpty {
            delegate.paymentQueue(SKPaymentQueue.default(), updatedTransactions: pending)
        }
    }
    
    deinit {
        Task.detached { [delegate] in
            delegate.handler = nil
            SKPaymentQueue.default().remove(delegate)
        }
    }
    
    public func retrieveSK1Product(with productID: String) async throws -> SKProduct {
        try await withCheckedThrowingContinuation { continuation in
            let request = SKProductsRequest(productIdentifiers: [productID])
            request.delegate = self.delegate
            productContinuations[request] = continuation
            request.start()
        }
    }
    
    public func retrieveSK1Products(from ids: [String]) async throws -> [SKProduct] {
        try await withCheckedThrowingContinuation { continuation in
            let request = SKProductsRequest(productIdentifiers: Set(ids))
            request.delegate = self.delegate
            productsContinuations[request] = continuation
            request.start()
        }
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
           
           Task {
               let payment: SKPayment
               
               switch product.subscriptionOffer {
               case .none:
                   payment = SKPayment(product: sk1product)
               case let .some(offer):
                   switch offer.offerIdentifier {
                   case .introductory:
                       payment = SKPayment(product: sk1product)
                   case .winBack:
                       throw BotsiError.customError("SK1. Winback offer error", "Storekit 1 does not support win back offers")
                   case let .promotional(offerId):
                       let repository = SignPromotionalOfferRepository(httpClient: client)
                       let useCase = SignPromotionalOfferUseCase(repository: repository)
                       
                       let signedOffer = try await useCase.getSignedPromotionalOffer(
                            productId: sk1product.productIdentifier,
                            offerId: offerId
                       )
                       payment = {
                           let payment = SKMutablePayment(product: sk1product)
                           payment.applicationUsername = ""
                           payment.paymentDiscount = SKPaymentDiscount(
                                offerId: offerId,
                                meta: signedOffer
                           )
                           return payment
                       }()
                   }
               }
               self.pendingProducts[payment.productIdentifier] = product
               
               SKPaymentQueue.default().add(payment)
           }
       }
    }
    
    public func restorePurchases() async throws -> BotsiProfile {
        return try await restoreTransactions()
    }
    
    internal func onDidReceiveProductsResponse(
        _ response: SKProductsResponse,
        from request: SKProductsRequest
    ) {
        if let cont = productContinuations.removeValue(forKey: request) {
            if let p = response.products.first {
                cont.resume(returning: p)
            } else {
                cont.resume(throwing: NSError(
                    domain: "StoreKit1Handler",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "No matching product"]
                ))
            }
            return
        }

        if let conts = productsContinuations.removeValue(forKey: request) {
            conts.resume(returning: response.products)
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
    
    internal func onDidFailRequest(
        _ error: Error,
        from request: SKRequest
    ) {
        if let req = request as? SKProductsRequest {
              if let cont = productContinuations.removeValue(forKey: req) {
                cont.resume(throwing: error)
              } else if let conts = productsContinuations.removeValue(forKey: req) {
                conts.resume(throwing: error)
              }
            }
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
            purchaseContinuation?.resume(throwing: BotsiError.customError("SK1. Purchase continuation error", error.localizedDescription))
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
        await storage.setProfile(profileFetched)
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
            await handler.onDidReceiveProductsResponse(response, from: request)
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        guard let handler = handler else { return }
        Task {
            await handler.onDidFailRequest(error, from: request) }
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

extension SKPaymentDiscount {
    typealias SignedOffer = BotsiSignSubscriptionOfferResponseData
    convenience init(offerId: String, meta: SignedOffer) {
        self.init(
            identifier: offerId,
            keyIdentifier: meta.keyId,
            nonce: meta.nonce,
            signature: meta.signature.base64EncodedString(),
            timestamp: Int(meta.timestamp)! as NSNumber
        )
    }
}

extension SKProductsResponse: @unchecked Sendable {}
extension SKRequest: @unchecked @retroactive Sendable {}
extension SKProduct: @unchecked Sendable {}
