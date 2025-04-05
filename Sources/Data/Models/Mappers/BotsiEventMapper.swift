//
//  BotsiEventMapper.swift
//  Botsi
//
//  Created by Vladyslav on 25.03.2025.
//

import Foundation

struct BotsiEventMapper: DomainMapper {

    typealias Parameters = (profileId: String, paywallId: String, abTestId: String?, eventType: String)
    
    typealias DTOResponseModel = BotsiEventsResponseDto
    
    typealias DTORequestModel = [BotsiEventsRequestDto]
    
    typealias DomainModel = Bool
    
    func toDTO(from parameters: Parameters) -> [BotsiEventsRequestDto] {
        var events: [BotsiEventsRequestDto] = []
        
        let event = BotsiEventsRequestDto(
            profileId: parameters.profileId,
            paywallId: parameters.paywallId,
            abTestId: parameters.abTestId,
            eventType: parameters.eventType
        )
        events.append(event)
        return events
    }
    
    func toDomain(from dto: BotsiEventsResponseDto) -> Bool {
        return dto.ok
    }
}
