//
//  BotsiUpdateProfileDto.swift
//  Botsi
//
//  Created by Vladyslav on 27.05.2025.
//

import Foundation


// MARK: - Request model
struct BotsiUpdateProfileRequestDto: Encodable {
    let ip: String
}

// MARK: - Response model
struct UpdateProfileDtoResponse: Codable {
    let ok: Bool
    let data: BotsiProfile
}

struct UpdateProfileErrorDtoResponse: Codable {
    let ok: Bool
    let message: String
    let status: Int
}
