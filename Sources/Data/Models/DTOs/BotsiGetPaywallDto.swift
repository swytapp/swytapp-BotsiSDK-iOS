//
//  BotsiGetPaywallDto.swift
//  Botsi
//
//  Created by Vladyslav on 22.03.2025.
//

import Foundation

// MARK: - Response model
struct BotsiGetPaywallResponseDto: Codable {
    let ok: Bool
    let data: BotsiPaywall
}
