//
//  BotsiUI+DefaultConfiguration.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

#if canImport(UIKit)

import Botsi
import UIKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
public extension BotsiPaywallControllerDelegate {
    func paywallController(
        _ controller: BotsiPaywallController,
        didPerform action: BotsiUI.Action
    ) {
        switch action {
        case .close:
            controller.dismiss(animated: true)
        case let .openURL(url):
            UIApplication.shared.open(url, options: [:])
        case .custom:
            break
        }
    }

    func paywallController(
        _ controller: BotsiPaywallController,
        didSelectProduct product: any BotsiPaywallProductWithoutDeterminingOffer
    ) {}

    func paywallController(
        _ controller: BotsiPaywallController,
        didStartPurchase product: BotsiPaywallProduct
    ) {}

    func paywallController(
        _ controller: BotsiPaywallController,
        didFinishPurchase product: BotsiPaywallProduct,
        purchaseResult: BotsiPurchaseResult
    ) {
        if !purchaseResult.isPurchaseCancelled {
            controller.dismiss(animated: true)
        }
    }

    func paywallControllerDidStartRestore(_ controller: BotsiPaywallController) {}

    func paywallController(
        _ controller: BotsiPaywallController,
        didFailRenderingWith error: BotsiError
    ) {}

    func paywallController(
        _ controller: BotsiPaywallController,
        didFailLoadingProductsWith error: BotsiError
    ) -> Bool {
        false
    }

    func paywallController(
        _ controller: BotsiPaywallController,
        didPartiallyLoadProducts failedIds: [String]
    ) {}
}

#endif
