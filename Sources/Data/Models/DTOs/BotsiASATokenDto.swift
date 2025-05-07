//
//  BotsiASATokenDto.swift
//  Botsi
//
//  Created by Vladyslav on 07.05.2025.
//

import Foundation

// MARK: - Request model
struct BotsiASATokenRequestDto: Encodable {
    let profileId: String
    let token: String
}

// MARK: - Response model
struct BotsiASATokenResponseDto: Codable {
    let ok: Bool
    let data: BotsiProfile
}
