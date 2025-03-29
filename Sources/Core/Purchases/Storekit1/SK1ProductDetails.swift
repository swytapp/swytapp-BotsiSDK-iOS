//
//  SK1ProductDetails.swift
//  Botsi
//
//  Created by Vladyslav on 23.03.2025.
//

import StoreKit

public struct SK1ProductDetails: Sendable {
    public let skProduct: SKProduct
    
    // Common Fields
    public let price: Decimal
    public let localizedPrice: String
    public let currencyCode: String?
    public let isEligibleForIntroOffer: Bool
    public let introductoryPrice: String?

    public init(
        skProduct: SKProduct,
        price: Decimal,
        localizedPrice: String,
        currencyCode: String?,
        isEligibleForIntroOffer: Bool,
        introductoryPrice: String?
    ) {
        self.skProduct = skProduct
        self.price = price
        self.localizedPrice = localizedPrice
        self.currencyCode = currencyCode
        self.isEligibleForIntroOffer = isEligibleForIntroOffer
        self.introductoryPrice = introductoryPrice
    }
}

extension SKProduct {
    /// Builds an `SK1ProductDetails` from an `SKProduct`.
    func toSK1ProductDetails() -> SK1ProductDetails {
        // Prepare a currency formatter for display
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        formatter.currencyCode = self.priceLocale.currencyCode

        let localizedPriceString = formatter.string(from: self.price) ?? "\(self.price)"
        
        // Check if there's an introductory price and (very basic) "eligibility"
        let introPrice = self.introductoryPrice?.price
        let introPriceString = introPrice.flatMap { formatter.string(from: $0) }
        let isEligibleForIntro = (self.introductoryPrice != nil)
        
        return SK1ProductDetails(
            skProduct: self,
            price: self.price as Decimal,
            localizedPrice: localizedPriceString,
            currencyCode: self.priceLocale.currencyCode,
            isEligibleForIntroOffer: isEligibleForIntro,
            introductoryPrice: introPriceString
        )
    }
}

