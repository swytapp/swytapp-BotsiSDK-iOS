//
//  BotsiEventMapper.swift
//  Botsi
//
//  Created by Vladyslav on 25.03.2025.
//

import Foundation

struct BotsiEventMapper: DomainMapper {

    typealias Parameters = (profileId: String, placementId: String, eventType: String)
    
    typealias DTOResponseModel = BotsiEventsResponseDto
    
    typealias DTORequestModel = BotsiEventsRequestDto
    
    typealias DomainModel = Bool
    
    func toDTO(from parameters: Parameters) -> BotsiEventsRequestDto {
        return BotsiEventsRequestDto(profileId: parameters.profileId, placementId: parameters.placementId, eventType: parameters.eventType)
    }
    
    func toDomain(from dto: BotsiEventsResponseDto) -> Bool {
        return dto.ok
    }
}
