//
//  UpdateAppleConsumptionConsentDto.swift
//  Botsi
//
//  Created by Vladyslav on 19.07.2025.
//

import Foundation

// MARK: - Request model
struct UpdateAppleConsumptionConsentRequestModel: Encodable {
    let appleConsumptionConsent: Bool
}

// MARK: - Response model
struct UpdateAppleConsumptionConsentResponseDto: Codable {
    let ok: Bool
}
