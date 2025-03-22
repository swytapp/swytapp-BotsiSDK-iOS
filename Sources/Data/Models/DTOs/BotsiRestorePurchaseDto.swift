//
//  BotsiRestorePurchaseDto.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//


import Foundation

// MARK: - Request model
struct BotsiRestorePurchaseRequestDto: Encodable {
    let originalTransactionId: String
    let profileId: String
    let storeCountry: String
    let botsiSdkVersion: String
    let appBuild: String
    let appVersion: String
    let device: String
    let locale: String
    let os: String
}

struct BotsiValidateReceiptRequestDto: Encodable {
    let receipt: Data
    let profileId: String
}

// MARK: - Response model
struct BotsiRestorePurchaseResponseDto: Codable {
    let ok: Bool
    let data: BotsiProfile
}
