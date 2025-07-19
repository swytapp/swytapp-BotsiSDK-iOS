//
//  BotsiProfileDto.swift
//  Botsi
//
//  Created by Vladyslav on 20.02.2025.
//

import Foundation


// MARK: - Request model
struct CreateProfileRequestDto: Encodable {
    let meta: CreateProfileMetaDto
}

struct CreateProfileMetaDto: Encodable {
    let customerUserId: String?
    let storeCountry: String
    let botsiSdkVersion: String
    let advertisingId: String
    let androidId: String
    let appBuild: String
    let androidAppSetId: String
    let appVersion: String
    let device: String
    let deviceId: String
    let locale: String
    let os: String
    let platform: String
    let timezone: String
    let birthday: String?
}

// MARK: - Response model
struct CreateProfileDtoResponse: Codable {
    let ok: Bool
    let data: BotsiProfile
}

struct CreateProfileErrorDtoResponse: Codable {
    let ok: Bool
    let message: String
    let status: Int
}
