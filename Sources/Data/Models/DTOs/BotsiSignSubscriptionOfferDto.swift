//
//  BotsiSignSubscriptionOfferDto.swift
//  Botsi
//
//  Created by Vladyslav on 19.04.2025.
//

import Foundation

// MARK: - Response model
struct BotsiSignSubscriptionOfferResponseDto: Decodable {
    let ok: Bool
    let data: BotsiSignSubscriptionOfferResponseData
}

struct BotsiSignSubscriptionOfferResponseData: Decodable {
    let keyId: String
    let nonce: UUID
    let timestamp: String
    let signature: Data
}
