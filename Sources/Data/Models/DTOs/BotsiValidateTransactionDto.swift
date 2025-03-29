//
//  BotsiValidationTransactionDto.swift
//  Botsi
//
//  Created by Vladyslav on 10.03.2025.
//

import Foundation


// MARK: - Request model
struct BotsiValidateTransactionRequestDto: Encodable {
    let transactionId: String
    let originalTransactionId: String
    let sourceProductId: String
    let originalPrice: Decimal
    let discountPrice: String
    let priceLocale: String
    let storeCountry: String
    let offer: BotsiValidateTransactionOfferDto
    let promotionalOfferId: String
    let environment: String
    let profileId: String
    let productId: String
    let placementId: String
    let paywallId: String
    let isSubscription: Bool
    
}

struct BotsiValidateTransactionOfferDto: Encodable {
    let periodUnit: String
    let numberOfUnits: Int
    let type: String
    let category: String
}

// MARK: - Response model
struct BotsiValidateTransactionResponseDto: Codable {
    let ok: Bool
    let data: BotsiProfile
}
