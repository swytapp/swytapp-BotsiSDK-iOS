//
//  BotsiEventMapper.swift
//  Botsi
//
//  Created by Vladyslav on 25.03.2025.
//

import Foundation

struct BotsiEventMapper: DomainMapper {

    typealias Parameters = (profileId: String, paywallId: Int?, abTestId: Int?, eventType: String, placementId: String, aiPricingModelId: Int?, isExperiment: Bool?)
    
    typealias DTOResponseModel = BotsiEventsResponseDto
    
    typealias DTORequestModel = [BotsiEventsRequestDto]
    
    typealias DomainModel = Bool
    
    func toDTO(from parameters: Parameters) -> [BotsiEventsRequestDto] {
        var events: [BotsiEventsRequestDto] = []
        
        let event = BotsiEventsRequestDto(
            profileId: parameters.profileId,
            paywallId: parameters.paywallId,
            abTestId: parameters.abTestId,
            eventType: parameters.eventType,
            placementId: parameters.placementId,
            aiPricingModelId: parameters.aiPricingModelId,
            isExperiment: parameters.isExperiment
        )
        events.append(event)
        return events
    }
    
    func toDomain(from dto: BotsiEventsResponseDto) -> Bool {
        return dto.ok
    }
}
