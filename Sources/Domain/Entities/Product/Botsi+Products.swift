//
//  Botsi+Products.swift
//  Botsi
//
//  Created by Vladyslav on 19.04.2025.
//

import StoreKit

@available(iOS 15.0, macOS 12.0, *)
extension Botsi {
    func getBotsiProducts(
        paywall: BotsiPaywall,
        handler: StoreKit2Handler
    ) async throws -> [BotsiProduct] {
        
        let identifiers = paywall.sourceProducts.compactMap { "\($0.sourcePoductId)" }
        
        let products: [ProductTupleSK2] = try await handler.retrieveProductAsync(with: identifiers)
            .compactMap { sk2Product in
                let sourceProduct = paywall.sourceProducts.first(where: { $0.sourcePoductId == sk2Product.id })!
                let (offer, subscriptionGroupId): (BotsiOffer?, String?) =
                    if let subscriptionGroupId = sk2Product.subscription?.subscriptionGroupID,
                       winBackOfferExist(with: sourceProduct.winBackOfferId, from: sk2Product) {
                        (nil, subscriptionGroupId)
                    } else {
                        (subscriptionOfferAvailable(sourceProduct, sk2Product), nil)
                    }
                return (sk2Product, sourceProduct, offer, subscriptionGroupId)
            }
        let eligibleWinBackOfferIds = try await eligibleWinBackOfferIds(for: Set(products.compactMap { $0.subscriptionGroupId }))
        if !eligibleWinBackOfferIds.isEmpty {
            BotsiLog.verbose("Eligible for winback offers.")
        }

        var newProducts = [(product: Product, reference: BotsiSourceProduct, offer: BotsiOffer?)]()
        newProducts.reserveCapacity(products.count)
        for product in products {
            await newProducts.append(determineOfferFor(product, with: eligibleWinBackOfferIds))
        }

        return newProducts.map {
            BotsiSK2PaywallProduct(
                skProduct: $0.product,
                paywallId: paywall.id,
                placementId: paywall.placementId,
                abTestId: paywall.abTestId,
                subscriptionOffer: $0.offer
            )
        }
    }

    private typealias ProductTupleSK2 = (
        product: Product,
        reference: BotsiSourceProduct,
        offer: BotsiOffer?,
        subscriptionGroupId: String?
    )

    private func subscriptionOfferAvailable(
        _ reference: BotsiSourceProduct,
        _ sk2Product: Product
    ) -> BotsiOffer? {
        BotsiLog.verbose("reference: \(reference.botsiProductId) \(reference.promotionalOfferId ?? "null") and product \(sk2Product.id)")
        if let promotionalOffer = promotionalOffer(with: reference.promotionalOfferId, from: sk2Product) {
            return promotionalOffer
        } else if sk2Product.introductoryOfferNotApplicable {
            return nil
        } else {
            return nil
        }
    }

    private func determineOfferFor(
        _ tuple: ProductTupleSK2,
        with eligibleWinBackOfferIds: [String: [String]]
    ) async -> (product: Product, reference: BotsiSourceProduct, offer: BotsiOffer?) {

        if let subscriptionGroupId = tuple.subscriptionGroupId,
           let winBackOfferId = tuple.reference.winBackOfferId
        {
            if eligibleWinBackOfferIds[subscriptionGroupId]?.contains(winBackOfferId) ?? false,
               let winBackOffer = winBackOffer(with: winBackOfferId, from: tuple.product)
            {
                
                return (tuple.product, tuple.reference, winBackOffer)
            }
        }
        
        if let subscription = tuple.product.subscription {
            let isIntroEligible = await subscription.isEligibleForIntroOffer
            if !isIntroEligible,
               let promoOffer = subscriptionOfferAvailable(tuple.reference, tuple.product)
            {
                BotsiLog.verbose("Promotional offer: \(promoOffer.description)")
                return (tuple.product, tuple.reference, promoOffer)
            }
        }
        
        if let subscription = tuple.product.subscription,
           let introductoryOffer = tuple.product.subscriptionOffer(by: .introductory)
        {
            let isIntroEligible = await subscription.isEligibleForIntroOffer
            if isIntroEligible {
                
                return (tuple.product, tuple.reference, introductoryOffer)
            }
        }
        
        return (tuple.product, tuple.reference, nil)
    }

    private func winBackOffer(with offerId: String?, from sk2Product: Product) -> BotsiOffer? {
        guard let offerId else { return nil }
        guard let offer = sk2Product.subscriptionOffer(by: .winBack(offerId)) else {
            BotsiLog.warn("no win back offer found with id:\(offerId) in productId:\(sk2Product.id)")
            return nil
        }
        return offer
    }

    private func promotionalOffer(with offerId: String?, from sk2Product: Product) -> BotsiOffer? {
        guard let offerId else { return nil }
        guard let offer = sk2Product.subscriptionOffer(by: .promotional(offerId)) else {
            BotsiLog.warn("no promotional offer found with id:\(offerId) in productId:\(sk2Product.id)")
            return nil
        }
        return offer
    }

    private func eligibleWinBackOfferIds(for subscriptionGroupIdentifiers: Set<String>) async throws -> [String: [String]] {
        var result = [String: [String]]()
        result.reserveCapacity(subscriptionGroupIdentifiers.count)
        for subscriptionGroupIdentifier in subscriptionGroupIdentifiers {
            result[subscriptionGroupIdentifier] = try await eligibleWinBackOfferIds(for: subscriptionGroupIdentifier)
        }
        return result
    }

    private func eligibleWinBackOfferIds(for subscriptionGroupIdentifier: String) async throws -> [String] {
        #if compiler(<6.0)
            return []
        #else
            guard #available(iOS 18.0, macOS 15.0, *) else { return [] }
            let statuses: [Product.SubscriptionInfo.Status]
            
            do {
                statuses = try await Product.SubscriptionInfo.status(for: subscriptionGroupIdentifier)
            } catch {
                BotsiLog.error("Status retrieving error: \(error.localizedDescription)")
                throw BotsiError.customError("winback", "error")
            }

            let status = statuses.first {
                guard case let .verified(transaction) = $0.transaction else { return false }
                guard transaction.ownershipType == .purchased else { return false }
                return true
            }

            guard case let .verified(renewalInfo) = status?.renewalInfo else { return [] }
            return renewalInfo.eligibleWinBackOfferIDs
        #endif
    }
    
    
    private func winBackOfferExist(with offerId: String?, from product: Product) -> Bool {
        guard let offerId else { return false }
        guard product.unfWinBackOffer(byId: offerId) != nil else {
            BotsiLog.info("No win back offer exists with identifier: \(offerId) for product: \(product.id)")
            return false
        }
        return true
    }
}

extension Botsi {
    func getBotsiProductsForSK1(
        profileId: String,
        paywall: BotsiPaywall,
        handler: StoreKit1Handler
    ) async throws -> [BotsiProduct] {
        typealias ProductTupleSK1 = (
            product: SKProduct,
            reference: BotsiSourceProduct,
            offer: BotsiOffer?,
            determinedOffer: Bool
        )
        
        let identifiers = paywall.sourceProducts.compactMap { "\($0.sourcePoductId)" }
        let sk1Products = try await handler.retrieveSK1Products(from: identifiers)
        
        var products: [ProductTupleSK1] = sk1Products.compactMap { sk1Product in

            guard let sourceProduct = paywall.sourceProducts.first(where: {
                $0.sourcePoductId == sk1Product.productIdentifier
            }) else { return nil }
            
            let (offer, determined): (BotsiOffer?, Bool) =
            if let promo = promotionalOffer(sourceProduct.promotionalOfferId, sk1Product) {
                (promo, true)
            } else if sk1Product.introductoryOfferNotApplicable {
                (nil, true)
            } else {
                (nil, false)
            }
            
            return (
                product: sk1Product,
                reference: sourceProduct,
                offer: offer,
                determinedOffer: determined
            )
        }
        let sourceProductIds: [String] = products.compactMap {
            guard !$0.determinedOffer else { return nil }
            return $0.product.productIdentifier
        }
        
        if !sourceProductIds.isEmpty {
            do {
                let repository = OfferEligibilityRepository(httpClient: botsiClient)
                let useCase = OfferEligibilityUseCase(repository: repository)
                let eligibleOffers = try await useCase.getEligibleOffers(
                    profileId: profileId, productIds: sourceProductIds
                ).map { $0.sourceProductId }
                
                products = products.map {
                    guard !$0.determinedOffer else { return $0 }
                    return if let introductoryOffer = $0.product.subscriptionOffer(by: .introductory),
                              eligibleOffers.contains($0.product.productIdentifier)
                    {
                        (product: $0.product, reference: $0.reference, offer: introductoryOffer, determinedOffer: true)
                    } else {
                        (product: $0.product, reference: $0.reference, offer: nil, determinedOffer: true)
                    }
                }
            } catch let error as BotsiError {
                print(error.localizedDescription)
            } catch {
                print(error.localizedDescription)
            }
        }

        return products.map {
            BotsiSK1PaywallProduct(
                skProduct: $0.product,
                paywallId: paywall.id,
                placementId: paywall.placementId,
                abTestId: paywall.abTestId,
                subscriptionOffer: $0.offer
            )
        }
    }
    
    private func promotionalOffer(_ offerId: String?, _ sk1Product: SKProduct) -> BotsiOffer? {
        guard let offerId else { return nil }
        guard let offer = sk1Product.subscriptionOffer(by: .promotional(offerId)) else {
            BotsiLog.warn("no promotional offer found with id:\(offerId) in productId:\(sk1Product.productIdentifier)")
            return nil
        }
        return offer
    }
}

extension SKProduct {
    typealias SubscriptionOffer = SKProductDiscount

    var introductoryOfferNotApplicable: Bool {
        if let period = subscriptionPeriod,
           period.numberOfUnits > 0,
           introductoryPrice != nil
        {
            false
        } else {
            true
        }
    }

    private var unfIntroductoryOffer: SubscriptionOffer? {
        introductoryPrice
    }

    private func unfPromotionalOffer(byId identifier: String) -> SKProduct.SubscriptionOffer? {
        discounts.first(where: { $0.identifier == identifier })
    }
    
    func subscriptionOffer(by offerIdentifier: BotsiOffer.Identifier) -> BotsiOffer? {
        let offer: SubscriptionOffer? =
            switch offerIdentifier {
            case .introductory:
                unfIntroductoryOffer
            case .promotional(let id):
                unfPromotionalOffer(byId: id)
            default:
                nil
            }
        guard let offer else { return nil }

        let period = offer.subscriptionPeriod
        let periodLocale = priceLocale
        let subscriptionPeriod = BotsiSubscriptionPeriod(
            unit: period.unit.asCutomPerioudUnit,
            numberOfUnits: period.numberOfUnits
        )

        return BotsiOffer(
            price: offer.price as Decimal,
            currencyCode: periodLocale.unfCurrencyCode,
            localizedPrice: periodLocale.localized(sk1Price: offer.price),
            offerIdentifier: offerIdentifier,
            subscriptionPeriod: subscriptionPeriod,
            numberOfPeriods: offer.numberOfPeriods,
            paymentMode: offer.paymentMode.asPaymentMode,
            localizedSubscriptionPeriod: periodLocale.localized(period: subscriptionPeriod),
            localizedNumberOfPeriods: periodLocale.localized(period: subscriptionPeriod, numberOfPeriods: offer.numberOfPeriods)
        )
    }
}
