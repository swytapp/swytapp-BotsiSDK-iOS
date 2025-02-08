//
//  BotsiPaywallInterface.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Botsi
import Foundation

package enum BotsiUIGetProductsResult: Sendable {
    case partial(products: [BotsiPaywallProduct], failedIds: [String])
    case full(products: [BotsiPaywallProduct])
}

@MainActor
package protocol BotsiPaywallInterface {
    var placementId: String { get }
    var variationId: String { get }
    var locale: String? { get }
    var vendorProductIds: [String] { get }

    func getPaywallProductsWithoutDeterminingOffer() async throws -> [BotsiPaywallProductWithoutDeterminingOffer]
    func getPaywallProducts() async throws -> BotsiUIGetProductsResult
    func logShowPaywall(viewConfiguration: BotsiViewConfiguration) async throws
}

extension BotsiPaywall: BotsiPaywallInterface {
    package var locale: String? { remoteConfig?.locale }

    package func getPaywallProductsWithoutDeterminingOffer() async throws -> [BotsiPaywallProductWithoutDeterminingOffer] {
        try await Botsi.getPaywallProductsWithoutDeterminingOffer(paywall: self)
    }

    package func getPaywallProducts() async throws -> BotsiUIGetProductsResult {
        let products = try await Botsi.getPaywallProducts(paywall: self)

        if products.count == vendorProductIds.count {
            return .full(products: products)
        } else {
            let failedIds = vendorProductIds.filter { productId in
                !products.contains(where: { $0.vendorProductId == productId })
            }
            return .partial(products: products, failedIds: failedIds)
        }
    }

    package func logShowPaywall(viewConfiguration: BotsiViewConfiguration) async throws {
        await Botsi.logShowPaywall(self, viewConfiguration: viewConfiguration)
    }
}
