//
//  BotsiOfferEligibilityMapper.swift
//  Botsi
//
//  Created by Vladyslav on 26.04.2025.
//

import Foundation

struct BotsiOfferEligibilityMapper: DomainMapper {
    typealias Parameters = Sendable

    typealias DTOResponseModel = BotsiOfferEligibilityDto
    
    typealias DTORequestModel = Int
    
    typealias DomainModel = [BotsiOfferEligibilityData]
    
    func toDTO(from model: any Parameters) -> Int { return 0 }
    
    func toDomain(from dto: BotsiOfferEligibilityDto) -> [BotsiOfferEligibilityData] {
        return dto.data
    }
}
