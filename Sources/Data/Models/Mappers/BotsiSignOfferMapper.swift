//
//  BotsiSignOfferMapper.swift
//  Botsi
//
//  Created by Vladyslav on 19.04.2025.
//

import Foundation

struct BotsiSignOfferMapper: DomainMapper {
    typealias Parameters = Sendable

    typealias DTOResponseModel = BotsiSignSubscriptionOfferResponseDto
    
    typealias DTORequestModel = Int
    
    typealias DomainModel = BotsiSignSubscriptionOfferResponseData
    
    func toDTO(from model: any Parameters) -> Int { return 0 }
    
    func toDomain(from dto: BotsiSignSubscriptionOfferResponseDto) -> BotsiSignSubscriptionOfferResponseData {
        return dto.data
    }
}
