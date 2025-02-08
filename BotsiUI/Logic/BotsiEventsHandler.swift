//
//  BotsiEventsHandler.swift
//
//
//  Created by Aleksey Goncharov on 17.06.2024.
//

#if canImport(UIKit)

import Botsi
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
package final class BotsiEventsHandler: ObservableObject {
    enum PresentationState {
        case initial
        case appeared
        case disappeared
    }

    let logId: String

    var didPerformAction: ((BotsiUI.Action) -> Void)?
    var didSelectProduct: ((BotsiPaywallProductWithoutDeterminingOffer) -> Void)?
    var didStartPurchase: ((BotsiPaywallProduct) -> Void)?
    var didFinishPurchase: ((BotsiPaywallProduct, BotsiPurchaseResult) -> Void)?
    var didFailPurchase: ((BotsiPaywallProduct, BotsiError) -> Void)?
    var didStartRestore: (() -> Void)?
    var didFinishRestore: ((BotsiProfile) -> Void)?
    var didFailRestore: ((BotsiError) -> Void)?
    var didFailRendering: ((BotsiError) -> Void)?
    var didFailLoadingProducts: ((BotsiError) -> Bool)?
    var didPartiallyLoadProducts: (([String]) -> Void)?

    package init(logId: String) {
        self.logId = logId
        self.didPerformAction = nil
        self.didSelectProduct = nil
        self.didStartPurchase = nil
        self.didFinishPurchase = nil
        self.didFailPurchase = nil
        self.didStartRestore = nil
        self.didFinishRestore = nil
        self.didFailRestore = nil
        self.didFailRendering = nil
        self.didFailLoadingProducts = nil
        self.didPartiallyLoadProducts = nil
    }

    @Published var presentationState: PresentationState = .initial

    func viewDidAppear() {
        presentationState = .appeared
    }

    func viewDidDisappear() {
        presentationState = .disappeared
    }

    func event_didPerformAction(_ action: BotsiUI.Action) {
        Log.ui.verbose("#\(logId)# event_didPerformAction: \(action)")
        didPerformAction?(action)
    }

    func event_didSelectProduct(_ product: BotsiPaywallProductWithoutDeterminingOffer) {
        Log.ui.verbose("#\(logId)# event_didSelectProduct: \(product.vendorProductId)")
        didSelectProduct?(product)
    }

    func event_didStartPurchase(product: BotsiPaywallProduct) {
        Log.ui.verbose("#\(logId)# makePurchase begin")
        didStartPurchase?(product)
    }

    func event_didFinishPurchase(
        product: BotsiPaywallProduct,
        purchaseResult: BotsiPurchaseResult
    ) {
        Log.ui.verbose("#\(logId)# event_didFinishPurchase: \(product.vendorProductId)")
        didFinishPurchase?(product, purchaseResult)
    }

    func event_didFailPurchase(
        product: BotsiPaywallProduct,
        error: BotsiError
    ) {
        Log.ui.verbose("#\(logId)# event_didFailPurchase: \(product.vendorProductId), \(error)")
        didFailPurchase?(product, error)
    }

    func event_didStartRestore() {
        Log.ui.verbose("#\(logId)# event_didStartRestore")
        didStartRestore?()
    }

    func event_didFinishRestore(with profile: BotsiProfile) {
        Log.ui.verbose("#\(logId)# event_didFinishRestore")
        didFinishRestore?(profile)
    }

    func event_didFailRestore(with error: BotsiError) {
        Log.ui.error("#\(logId)# event_didFailRestore: \(error)")
        didFailRestore?(error)
    }

    func event_didFailRendering(with error: BotsiUIError) {
        Log.ui.error("#\(logId)# event_didFailRendering: \(error)")
        didFailRendering?(BotsiError(error))
    }

    func event_didFailLoadingProducts(with error: BotsiError) -> Bool {
        Log.ui.error("#\(logId)# event_didFailLoadingProducts: \(error)")
        return didFailLoadingProducts?(error) ?? false
    }

    func event_didPartiallyLoadProducts(failedProductIds: [String]) {
        Log.ui.error("#\(logId)# event_didPartiallyLoadProducts: \(failedProductIds)")
        didPartiallyLoadProducts?(failedProductIds)
    }
}

#endif
