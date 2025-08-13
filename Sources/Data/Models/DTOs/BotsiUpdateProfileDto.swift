//
//  BotsiUpdateProfileDto.swift
//  Botsi
//
//  Created by Vladyslav on 27.05.2025.
//

import Foundation


// MARK: - Request model
struct BotsiUpdateProfileRequestDto: Encodable {
    let birthday: String?
    let email: String?
    let username: String?
    let gender: BotsiGender?
    let phone: String?
    let custom: [BotsiProfile.BotsiCustomEntry]?
    let idfa: String?
    let advertisingId: String?
    let ip: String?
    
    init(
        birthday: String? = nil,
        email: String? = nil,
        username: String? = nil,
        gender: BotsiGender? = nil,
        phone: String? = nil,
        custom: [BotsiProfile.BotsiCustomEntry]? = nil,
        idfa: String? = nil,
        advertisingId: String? = nil,
        ip: String? = nil
    ) {
        self.birthday = birthday
        self.email = email
        self.username = username
        self.gender = gender
        self.phone = phone
        self.custom = custom
        self.idfa = idfa
        self.advertisingId = advertisingId
        self.ip = ip
    }
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
