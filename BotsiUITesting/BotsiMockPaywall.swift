//
//  BotsiMockPaywall.swift
//
//
//  Created by Aleksey Goncharov on 18.06.2024.
//

import Botsi
import BotsiUI
import Foundation

struct BotsiMockPaywall: BotsiPaywallInterface {
    var placementId: String { "mock" }
    var variationId: String { "mock" }
    var locale: String? { nil }
    var vendorProductIds: [String] { [] }

    func getPaywallProductsWithoutDeterminingOffer() async throws -> [any BotsiPaywallProductWithoutDeterminingOffer] {
        []
    }

    func getPaywallProducts() async throws -> BotsiUIGetProductsResult {
        .full(products: [])
    }

    func logShowPaywall(viewConfiguration: BotsiViewConfiguration) async throws {}
}
