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
    let paywallId: Int?
    let abTestId: Int?
    let eventType: String
}

// MARK: - Response model
struct BotsiEventsResponseDto: Codable {
    let ok: Bool
}
