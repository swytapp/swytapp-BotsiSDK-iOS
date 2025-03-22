//
//  BotsiGetPaywallMapper.swift
//  Botsi
//
//  Created by Vladyslav on 22.03.2025.
//

import Foundation

struct BotsiGetPaywallMapper: DomainMapper {

    typealias Parameters = (profileId: String, receipt: Data)
    
    typealias DTOResponseModel = BotsiGetPaywallResponseDto
    
    typealias DTORequestModel = String
    
    typealias DomainModel = BotsiPaywall
    
    func toDTO(from parameters: Parameters) -> String { return "" }
    
    func toDomain(from dto: BotsiGetPaywallResponseDto) -> BotsiPaywall {
        return dto.data
    }
}
