//
//  SK2ProductFetcher.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 03.10.2024
//

import StoreKit

private let log = Log.sk2ProductManager

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
actor SK2ProductFetcher {
    func fetchProducts(ids productIds: Set<String>, retryCount: Int = 3) async throws -> [SK2Product] {
        log.verbose("Called fetch SK2Products: \(productIds) retryCount:\(retryCount)")

        let stamp = Log.stamp
        await Botsi.trackSystemEvent(BotsiAppleRequestParameters(
            methodName: .fetchSK2Products,
            stamp: stamp,
            params: [
                "products_ids": productIds,
            ]
        ))

        let sk2Products: [SK2Product]
        do {
            sk2Products = try await SK2Product.products(for: productIds)
        } catch {
            log.error("Can't fetch SK2Products from Store \(error)")

            await Botsi.trackSystemEvent(BotsiAppleResponseParameters(
                methodName: .fetchSK2Products,
                stamp: stamp,
                error: "\(error.localizedDescription). Detail: \(error)"
            ))

            throw StoreKitManagerError.requestSK2ProductsFailed(error).asBotsiError
        }

        if sk2Products.isEmpty {
            log.verbose("fetch SK2Products result is empty")
        }

        for sk2Product in sk2Products {
            log.verbose("Found SK2Product \(sk2Product.id) \(sk2Product.displayName) \(sk2Product.displayPrice)")
        }

        await Botsi.trackSystemEvent(BotsiAppleResponseParameters(
            methodName: .fetchSK2Products,
            stamp: stamp,
            params: [
                "products_ids": sk2Products.map { $0.id },
            ]
        ))

        return sk2Products
    }
}
