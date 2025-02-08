//
//  SK1PaywallProducts.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 23.05.2023
//

import Foundation

private let log = Log.sk1ProductManager

extension Botsi {
    func getSK1PaywallProductsWithoutOffers(
        paywall: BotsiPaywall,
        productsManager: SK1ProductsManager
    ) async throws -> [BotsiPaywallProductWithoutDeterminingOffer] {
        try await productsManager.fetchSK1ProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )
        .compactMap { sk1Product in
            let vendorId = sk1Product.productIdentifier
            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            return BotsiSK1PaywallProductWithoutDeterminingOffer(
                skProduct: sk1Product,
                botsiProductId: reference.botsiProductId,
                variationId: paywall.variationId,
                paywallABTestName: paywall.abTestName,
                paywallName: paywall.name
            )
        }
    }

    func getSK1PaywallProduct(
        vendorProductId: String,
        botsiProductId: String,
        subscriptionOfferIdentifier: BotsiSubscriptionOffer.Identifier?,
        variationId: String,
        paywallABTestName: String,
        paywallName: String,
        productsManager: SK1ProductsManager
    ) async throws -> BotsiSK1PaywallProduct {
        let sk1Product = try await productsManager.fetchSK1Product(id: vendorProductId, fetchPolicy: .returnCacheDataElseLoad)

        let subscriptionOffer: BotsiSubscriptionOffer? =
            if let subscriptionOfferIdentifier {
                if let offer = sk1Product.subscriptionOffer(by: subscriptionOfferIdentifier) {
                    offer
                } else {
                    throw StoreKitManagerError.invalidOffer("StoreKit1 product dont have offer id: `\(subscriptionOfferIdentifier.identifier ?? "nil")` with type:\(subscriptionOfferIdentifier.asOfferType.rawValue) ").asBotsiError
                }
            } else {
                nil
            }

        return BotsiSK1PaywallProduct(
            skProduct: sk1Product,
            botsiProductId: botsiProductId,
            subscriptionOffer: subscriptionOffer,
            variationId: variationId,
            paywallABTestName: paywallABTestName,
            paywallName: paywallName
        )
    }

    func getSK1PaywallProducts(
        paywall: BotsiPaywall,
        productsManager: SK1ProductsManager
    ) async throws -> [BotsiPaywallProduct] {
        typealias ProductTuple = (
            product: SK1Product,
            reference: BotsiPaywall.ProductReference,
            offer: BotsiSubscriptionOffer?,
            determinedOffer: Bool
        )

        let sk1Products = try await productsManager.fetchSK1ProductsInSameOrder(
            ids: paywall.vendorProductIds,
            fetchPolicy: .returnCacheDataElseLoad
        )

        var products: [ProductTuple] = sk1Products.compactMap { sk1Product in
            let vendorId = sk1Product.productIdentifier
            guard let reference = paywall.products.first(where: { $0.vendorId == vendorId }) else {
                return nil
            }

            let (offer, determinedOffer): (BotsiSubscriptionOffer?, Bool) =
                if let promotionalOffer = promotionalOffer(reference.promotionalOfferId, sk1Product) {
                    (promotionalOffer, true)
                } else if sk1Product.introductoryOfferNotApplicable {
                    (nil, true)
                } else {
                    (nil, false)
                }

            return (product: sk1Product, reference: reference, offer: offer, determinedOffer: determinedOffer)
        }

        let vendorProductIds: [String] = products.compactMap {
            guard !$0.determinedOffer else { return nil }
            return $0.product.productIdentifier
        }

        if !vendorProductIds.isEmpty {
            let introductoryOfferEligibility = await getIntroductoryOfferEligibility(vendorProductIds: vendorProductIds)
            products = products.map {
                guard !$0.determinedOffer else { return $0 }
                return if let introductoryOffer = $0.product.subscriptionOffer(by: .introductory),
                          introductoryOfferEligibility.contains($0.product.productIdentifier)
                {
                    (product: $0.product, reference: $0.reference, offer: introductoryOffer, determinedOffer: true)
                } else {
                    (product: $0.product, reference: $0.reference, offer: nil, determinedOffer: true)
                }
            }
        }

        return products.map {
            BotsiSK1PaywallProduct(
                skProduct: $0.product,
                botsiProductId: $0.reference.botsiProductId,
                subscriptionOffer: $0.offer,
                variationId: paywall.variationId,
                paywallABTestName: paywall.abTestName,
                paywallName: paywall.name
            )
        }
    }

    private func promotionalOffer(_ offerId: String?, _ sk1Product: SK1Product) -> BotsiSubscriptionOffer? {
        guard let offerId else { return nil }
        guard let offer = sk1Product.subscriptionOffer(by: .promotional(offerId)) else {
            log.warn("no promotional offer found with id:\(offerId) in productId:\(sk1Product.productIdentifier)")
            return nil
        }
        return offer
    }

    private func getProfileState() -> (profileId: String, ineligibleProductIds: Set<String>)? {
        guard let manager = profileManager else { return nil }

        return (
            manager.profileId,
            manager.backendIntroductoryOfferEligibilityStorage.getIneligibleProductIds()
        )
    }

    private func getIntroductoryOfferEligibility(vendorProductIds: [String]) async -> [String] {
        guard let profileState = getProfileState() else { return [] }
        let (profileId, ineligibleProductIds) = profileState

        let vendorProductIds = vendorProductIds.filter { !ineligibleProductIds.contains($0) }
        guard !vendorProductIds.isEmpty else { return [] }

        if !profileStorage.syncedTransactions {
            do {
                try await syncTransactions(for: profileId)
            } catch {
                return []
            }
        }

        let lastResponse = try? profileManager(with: profileId)?.backendIntroductoryOfferEligibilityStorage.getLastResponse()
        do {
            let response = try
                await httpSession.fetchIntroductoryOfferEligibility(
                    profileId: profileId,
                    responseHash: lastResponse?.hash
                ).flatValue()

            guard let response else { return lastResponse?.eligibleProductIds ?? [] }

            if let manager = try? profileManager(with: profileId) {
                return manager.backendIntroductoryOfferEligibilityStorage.save(response)
            } else {
                return response.value.filter(\.value).map(\.vendorId)
            }

        } catch {
            return []
        }
    }
}
