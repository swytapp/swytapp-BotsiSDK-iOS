//
//  SK1QueueManager.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 25.10.2022
//

import StoreKit

private let log = Log.sk1QueueManager

actor SK1QueueManager: Sendable {
    private let purchaseValidator: PurchaseValidator
    private let productsManager: StoreKitProductsManager
    private let storage: VariationIdStorage

    private var makePurchasesCompletionHandlers = [String: [BotsiResultCompletion<BotsiPurchaseResult>]]()
    private var makePurchasesProduct = [String: SK1Product]()

    fileprivate init(purchaseValidator: PurchaseValidator, productsManager: StoreKitProductsManager, storage: VariationIdStorage) {
        self.purchaseValidator = purchaseValidator
        self.productsManager = productsManager
        self.storage = storage
    }

    func makePurchase(
        profileId: String,
        product: BotsiPaywallProduct
    ) async throws -> BotsiPurchaseResult {
        guard SKPaymentQueue.canMakePayments() else {
            throw BotsiError.cantMakePayments()
        }

        guard let sk1Product = product.sk1Product else {
            throw BotsiError.cantMakePayments()
        }

        let variationId = product.variationId

        let payment: SKPayment

        switch product.subscriptionOffer {
        case .none:
            payment = SKPayment(product: sk1Product)
        case let .some(offer):
            switch offer.offerIdentifier {
            case .introductory:
                payment = SKPayment(product: sk1Product)
            case .winBack:
                throw StoreKitManagerError.invalidOffer("StoreKit1 Does not support winBackOffer purchase").asBotsiError
            case let .promotional(offerId):

                let response = try await purchaseValidator.signSubscriptionOffer(
                    profileId: profileId,
                    vendorProductId: product.vendorProductId,
                    offerId: offerId
                )

                payment = {
                    let payment = SKMutablePayment(product: sk1Product)
                    payment.applicationUsername = ""
                    payment.paymentDiscount = SK1PaymentDiscount(
                        offerId: offerId,
                        signature: response
                    )

                    return payment
                }()
            }
        }

        return try await addPayment(
            payment,
            for: sk1Product,
            with: variationId
        )
    }

    func makePurchase(
        product: BotsiDeferredProduct
    ) async throws -> BotsiPurchaseResult {
        try await addPayment(product.payment, for: product.skProduct)
    }

    @inlinable
    func addPayment(
        _ payment: SKPayment,
        for underlying: SK1Product,
        with variationId: String? = nil
    ) async throws -> BotsiPurchaseResult {
        try await withCheckedThrowingContinuation { continuation in
            addPayment(payment, for: underlying, with: variationId) { result in
                continuation.resume(with: result)
            }
        }
    }

    private func addPayment(
        _ payment: SKPayment,
        for underlying: SK1Product,
        with variationId: String? = nil,
        _ completion: @escaping BotsiResultCompletion<BotsiPurchaseResult>
    ) {
        let productId = payment.productIdentifier

        makePurchasesProduct[productId] = underlying

        if let handlers = self.makePurchasesCompletionHandlers[productId] {
            self.makePurchasesCompletionHandlers[productId] = handlers + [completion]
            return
        }

        self.makePurchasesCompletionHandlers[productId] = [completion]

        Task {
            await storage.setVariationIds(variationId, for: productId)

            await Botsi.trackSystemEvent(BotsiAppleRequestParameters(
                methodName: .addPayment,
                params: [
                    "product_id": productId,
                ]
            ))

            SKPaymentQueue.default().add(payment)
        }
    }

    fileprivate func updatedTransactions(_ transactions: [SKPaymentTransaction]) async {
        for sk1Transaction in transactions {
            let logParams = sk1Transaction.logParams

            await Botsi.trackSystemEvent(BotsiAppleEventQueueHandlerParameters(
                eventName: "updated_transaction",
                params: logParams,
                error: sk1Transaction.error.map { "\($0.localizedDescription). Detail: \($0)" }
            ))

            switch sk1Transaction.transactionState {
            case .purchased:
                guard let id = sk1Transaction.transactionIdentifier else {
                    log.error("received purchased transaction without identifier")
                    return
                }

                await receivedPurchasedTransaction(SK1TransactionWithIdentifier(sk1Transaction, id: id))
            case .failed:
                SKPaymentQueue.default().finishTransaction(sk1Transaction)
                await Botsi.trackSystemEvent(BotsiAppleRequestParameters(
                    methodName: .finishTransaction,
                    params: logParams
                ))
                log.verbose("finish failed transaction \(sk1Transaction)")
                receivedFailedTransaction(sk1Transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(sk1Transaction)
                await Botsi.trackSystemEvent(BotsiAppleRequestParameters(
                    methodName: .finishTransaction,
                    params: logParams
                ))
                log.verbose("finish restored transaction \(sk1Transaction)")
            default:
                break
            }
        }
    }

    private func receivedPurchasedTransaction(_ sk1Transaction: SK1TransactionWithIdentifier) async {
        let productId = sk1Transaction.unfProductID

        let (variationId, persistentVariationId) = await storage.getVariationIds(for: productId)

        let purchasedTransaction: PurchasedTransaction =
            if let sk1Product = makePurchasesProduct[productId] {
                PurchasedTransaction(
                    sk1Product: sk1Product,
                    variationId: variationId,
                    persistentVariationId: persistentVariationId,
                    sk1Transaction: sk1Transaction
                )
            } else {
                await productsManager.fillPurchasedTransaction(
                    variationId: variationId,
                    persistentVariationId: persistentVariationId,
                    sk1Transaction: sk1Transaction
                )
            }

        let result: BotsiResult<BotsiPurchaseResult>
        do {
            let response = try await purchaseValidator.validatePurchase(
                profileId: nil,
                transaction: purchasedTransaction,
                reason: .purchasing
            )

            storage.removeVariationIds(for: productId)
            makePurchasesProduct.removeValue(forKey: productId)

            SKPaymentQueue.default().finishTransaction(sk1Transaction.underlay)

            await Botsi.trackSystemEvent(BotsiAppleRequestParameters(
                methodName: .finishTransaction,
                params: sk1Transaction.logParams
            ))

            log.info("finish purchased transaction \(sk1Transaction.underlay)")

            result = .success(.success(profile: response.value, transaction: sk1Transaction))

        } catch {
            result = .failure(error.asBotsiError ?? BotsiError.validatePurchaseFailed(unknownError: error))
        }

        callMakePurchasesCompletionHandlers(productId, result)
    }

    private func receivedFailedTransaction(_ sk1Transaction: SK1Transaction) {
        let productId = sk1Transaction.unfProductID
        storage.removeVariationIds(for: productId)
        makePurchasesProduct.removeValue(forKey: productId)

        let result: BotsiResult<BotsiPurchaseResult>
        if (sk1Transaction.error as? SKError)?.isPurchaseCancelled ?? false {
            result = .success(.userCancelled)
        } else {
            let error = StoreKitManagerError.productPurchaseFailed(sk1Transaction.error).asBotsiError
            result = .failure(error)
        }
        callMakePurchasesCompletionHandlers(productId, result)
    }

    private func callMakePurchasesCompletionHandlers(
        _ productId: String,
        _ result: BotsiResult<BotsiPurchaseResult>
    ) {
        switch result {
        case let .failure(error):

            log.error("Failed to purchase product: \(productId) \(error.localizedDescription)")
        case .success:
            log.info("Successfully purchased product: \(productId).")
        }

        guard let handlers = makePurchasesCompletionHandlers.removeValue(forKey: productId) else {
            log.error("Not found makePurchasesCompletionHandlers for \(productId)")
            return
        }

        for completion in handlers {
            completion(result)
        }
    }
}

extension SK1QueueManager {
    @BotsiActor
    private static var observer: SK1PaymentTransactionObserver?

    @BotsiActor
    static func startObserving(purchaseValidator: PurchaseValidator, productsManager: StoreKitProductsManager, storage: VariationIdStorage) -> SK1QueueManager? {
        guard observer == nil else { return nil }

        let manager = SK1QueueManager(
            purchaseValidator: purchaseValidator,
            productsManager: productsManager,
            storage: storage
        )

        let observer = SK1PaymentTransactionObserver(manager)
        self.observer = observer
        SKPaymentQueue.default().add(observer)
        return manager
    }

    private final class SK1PaymentTransactionObserver: NSObject, SKPaymentTransactionObserver, @unchecked Sendable {
        private let wrapped: SK1QueueManager

        init(_ wrapped: SK1QueueManager) {
            self.wrapped = wrapped
            super.init()
        }

        func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            Task {
                await wrapped.updatedTransactions(transactions)
            }
        }

        #if !os(watchOS)
            func paymentQueue(_: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for sk1Product: SKProduct) -> Bool {
                guard let delegate = Botsi.delegate else { return true }
                let deferredProduct = BotsiDeferredProduct(sk1Product: sk1Product, payment: payment)
                return delegate.shouldAddStorePayment(for: deferredProduct)
            }
        #endif
    }
}
