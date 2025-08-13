//
//  BotsiUpdateRefundConsentMapper.swift
//  Botsi
//
//  Created by Vladyslav on 19.07.2025.
//

import Foundation

struct BotsiUpdateRefundConsentMapper: DomainMapper {
    typealias DomainModel = Bool
    
    typealias Parameters = Bool
    
    typealias DTOResponseModel = UpdateAppleConsumptionConsentResponseDto
    
    typealias DTORequestModel = UpdateAppleConsumptionConsentRequestModel
    
    func toDTO(from parameters: Parameters) -> UpdateAppleConsumptionConsentRequestModel {
        return UpdateAppleConsumptionConsentRequestModel(appleConsumptionConsent: parameters)
    }
    
    func toDomain(from dto: UpdateAppleConsumptionConsentResponseDto) -> DomainModel {
        return dto.ok
    }
}
