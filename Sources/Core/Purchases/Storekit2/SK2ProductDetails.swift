//
//  SK2ProductDetails.swift
//  Botsi
//
//  Created by Vladyslav on 23.03.2025.
//

import StoreKit

@available(iOS 15.0, *)
public struct SK2ProductDetails: Sendable {
    public let product: Product
    
    // Common Fields
    public let price: Decimal
    public let localizedPrice: String
    public let currencyCode: String?
    public let isEligibleForIntroOffer: Bool
    public let introductoryPrice: String?
    
    public init(
        product: Product,
        price: Decimal,
        localizedPrice: String,
        currencyCode: String?,
        isEligibleForIntroOffer: Bool,
        introductoryPrice: String?
    ) {
        self.product = product
        self.price = price
        self.localizedPrice = localizedPrice
        self.currencyCode = currencyCode
        self.isEligibleForIntroOffer = isEligibleForIntroOffer
        self.introductoryPrice = introductoryPrice
    }
}

@available(iOS 15.0, *)
extension Product {
    func toSK2ProductDetails() async -> SK2ProductDetails {
        let numericPrice = self.price
        
        let isIntroEligible = await self.subscription?.isEligibleForIntroOffer ?? false
        let introPriceStr = self.subscription?.introductoryOffer?.displayPrice
        
        return SK2ProductDetails(
            product: self,
            price: numericPrice,
            localizedPrice: self.displayPrice,
            currencyCode: self.priceFormatStyle.currencyCode,
            isEligibleForIntroOffer: isIntroEligible,
            introductoryPrice: introPriceStr
        )
    }
}
