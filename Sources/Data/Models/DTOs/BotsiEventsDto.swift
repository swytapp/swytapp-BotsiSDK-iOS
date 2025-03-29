//
//  BotsiEventsDto.swift
//  Botsi
//
//  Created by Vladyslav on 25.03.2025.
//

import Foundation

// MARK: - Request model
struct BotsiEventsRequestDto: Encodable {
    let profileId: String
    let placementId: String
    let eventType: String
    /*let timestamp: String
    let productDuration: String
    let productId: [String] // ??
    let country: String
    let store: String
    let offerType: String
    let offerCategory: String
    let offerId: String
    let transactionId: String
    let originalTransactionId: String
    let revenueUsd: Decimal
    let proceedsUsd: Decimal
    let revenueLocal: Decimal
    let proceedsLocal: Decimal
    let purchaseCurrency: String
    let cancellationReason: String
    let subscriptionExpiresAt: String*/
}

// MARK: - Response model
struct BotsiEventsResponseDto: Codable {
    let ok: Bool
}
