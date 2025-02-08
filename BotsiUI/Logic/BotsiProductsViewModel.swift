//
//  BotsiProductsViewModel.swift
//
//
//  Created by Aleksey Goncharov on 27.05.2024.
//

#if canImport(UIKit)

import Botsi
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
protocol ProductsInfoProvider {
    func selectedProductInfo(by groupId: String) -> ProductInfoModel?
    func productInfo(by botsiId: String) -> ProductInfoModel?
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension BotsiProductsViewModel: ProductsInfoProvider {
    func selectedProductInfo(by groupId: String) -> ProductInfoModel? {
        guard let selectedProductId = selectedProductId(by: groupId) else { return nil }
        return productInfo(by: selectedProductId)
    }

    func productInfo(by botsiId: String) -> ProductInfoModel? {
        let underlying = products.first(where: { $0.botsiProductId == botsiId })
        return underlying
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class BotsiProductsViewModel: ObservableObject {
    private let queue = DispatchQueue(label: "BotsiUI.SDK.BotsiProductsViewModel.Queue")

    let logId: String
    private let eventsHandler: BotsiEventsHandler
    private let paywallViewModel: BotsiPaywallViewModel
    private let observerModeResolver: BotsiObserverModeResolver?

    @Published private var paywallProductsWithoutOffer: [BotsiPaywallProductWithoutDeterminingOffer]?
    @Published private var paywallProducts: [BotsiPaywallProduct]?

    var products: [BotsiPaywallProductWrapper] {
        return
            paywallProducts?.map { .full($0) } ??
            paywallProductsWithoutOffer?.map { .withoutOffer($0) } ??
            []
    }

    @Published var selectedProductsIds: [String: String]
    @Published var productsLoadingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    package init(
        eventsHandler: BotsiEventsHandler,
        paywallViewModel: BotsiPaywallViewModel,
        products: [BotsiPaywallProduct]?,
        observerModeResolver: BotsiObserverModeResolver?
    ) {
        logId = eventsHandler.logId
        self.eventsHandler = eventsHandler
        self.paywallViewModel = paywallViewModel

        paywallProducts = products
        selectedProductsIds = paywallViewModel.viewConfiguration.selectedProducts

        self.observerModeResolver = observerModeResolver
    }

    func loadProductsIfNeeded() {
        guard !productsLoadingInProgress, paywallProducts == nil else { return }

        if paywallProductsWithoutOffer != nil {
            loadProducts()
        } else {
            loadProductsWithoutOffers()
        }
    }

    func selectedProductId(by groupId: String) -> String? {
        selectedProductsIds[groupId]
    }

    func selectProduct(id: String, forGroupId groupId: String) {
        selectedProductsIds[groupId] = id

        if let selectedProduct = products.first(where: { $0.botsiProductId == id }) {
            eventsHandler.event_didSelectProduct(selectedProduct.anyProduct)
        }
    }

    func unselectProduct(forGroupId groupId: String) {
        selectedProductsIds.removeValue(forKey: groupId)
    }

    private func loadProductsWithoutOffers() {
        productsLoadingInProgress = true
        let logId = logId
        Log.ui.verbose("#\(logId)# loadProducts begin")

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                self.paywallProductsWithoutOffer = try await self.paywallViewModel.paywall.getPaywallProductsWithoutDeterminingOffer()
                self.loadProducts()
            } catch {
                Log.ui.error("#\(logId)# loadProducts fail: \(error)")
                self.productsLoadingInProgress = false

                if self.eventsHandler.event_didFailLoadingProducts(with: error.asBotsiError) {
                    Task {
                        try await Task.sleep(seconds: 2)
                        self.loadProductsIfNeeded()
                    }
                }
            }
        }
    }

    private func loadProducts() {
        productsLoadingInProgress = true
        let logId = logId
        Log.ui.verbose("#\(logId)# loadProducts begin")

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                let paywallProducts: [BotsiPaywallProduct]
                let productsResult = try await self.paywallViewModel.paywall.getPaywallProducts()

                switch productsResult {
                case .partial(let products, let failedIds):
                    Log.ui.warn("#\(logId)# loadProducts partial!")
                    paywallProducts = products
                    self.eventsHandler.event_didPartiallyLoadProducts(failedProductIds: failedIds)
                case .full(let products):
                    Log.ui.verbose("#\(logId)# loadProducts success")
                    paywallProducts = products
                }

                self.paywallProducts = paywallProducts
                self.productsLoadingInProgress = false
            } catch {
                Log.ui.error("#\(logId)# loadProducts fail: \(error)")
                self.productsLoadingInProgress = false

                if self.eventsHandler.event_didFailLoadingProducts(with: error.asBotsiError) {
                    Task {
                        try await Task.sleep(seconds: 2)
                        self.loadProductsIfNeeded()
                    }
                }
            }
        }
    }

    // MARK: Actions

    func purchaseSelectedProduct(fromGroupId groupId: String) {
        guard let productId = selectedProductId(by: groupId) else { return }
        purchaseProduct(id: productId)
    }

    func purchaseProduct(id productId: String) {
        guard let product = paywallProducts?.first(where: { $0.botsiProductId == productId }) else {
            Log.ui.warn("#\(logId)# purchaseProduct unable to purchase \(productId)")
            return
        }

        let logId = logId
        if let observerModeResolver {
            observerModeResolver.observerMode(
                didInitiatePurchase: product,
                onStartPurchase: { [weak self] in
                    Log.ui.verbose("#\(logId)# observerDidStartPurchase")
                    self?.purchaseInProgress = true
                },
                onFinishPurchase: { [weak self] in
                    Log.ui.verbose("#\(logId)# observerDidFinishPurchase")
                    self?.purchaseInProgress = false
                }
            )
        } else {
            eventsHandler.event_didStartPurchase(product: product)
            purchaseInProgress = true

            Task { @MainActor [weak self] in
                do {
                    let purchaseResult = try await Botsi.makePurchase(product: product)
                    self?.eventsHandler.event_didFinishPurchase(
                        product: product,
                        purchaseResult: purchaseResult
                    )
                } catch {
                    let botsiError = error.asBotsiError

                    if botsiError.botsiErrorCode == .paymentCancelled {
                        self?.eventsHandler.event_didFinishPurchase(
                            product: product,
                            purchaseResult: .userCancelled
                        )
                    } else {
                        self?.eventsHandler.event_didFailPurchase(product: product, error: botsiError)
                    }
                }

                self?.purchaseInProgress = false
            }
        }
    }

    func restorePurchases() {
        eventsHandler.event_didStartRestore()

        restoreInProgress = true

        Task { @MainActor [weak self] in
            do {
                let profile = try await Botsi.restorePurchases()
                self?.eventsHandler.event_didFinishRestore(with: profile)
            } catch {
                self?.eventsHandler.event_didFailRestore(with: error.asBotsiError)
            }

            self?.restoreInProgress = false
        }
    }
}

struct BotsiUIUnknownError: CustomBotsiError {
    let error: Error

    init(error: Error) {
        self.error = error
    }

    var originalError: Error? { error }
    let botsiErrorCode = BotsiError.ErrorCode.unknown

    var description: String { error.localizedDescription }
    var debugDescription: String { error.localizedDescription }
}

extension Error {
    var asBotsiError: BotsiError {
        if let botsiError = self as? BotsiError {
            return botsiError
        } else if let customError = self as? CustomBotsiError {
            return customError.asBotsiError
        }

        return BotsiError(BotsiUIUnknownError(error: self))
    }
}

#endif
