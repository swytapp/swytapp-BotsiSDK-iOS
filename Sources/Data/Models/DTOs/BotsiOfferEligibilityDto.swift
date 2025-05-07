//
//  BotsiOfferEligibilityDto.swift
//  Botsi
//
//  Created by Vladyslav on 26.04.2025.
//

// MARK: - Response model
struct BotsiOfferEligibilityDto: Decodable {
    let ok: Bool
    let data: [BotsiOfferEligibilityData]
}

struct BotsiOfferEligibilityData: Decodable {
    let sourceProductId: String
    let isEligibile: Bool
    let timestamp: Int
    
}
