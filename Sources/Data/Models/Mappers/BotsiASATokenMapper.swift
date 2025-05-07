//
//  BotsiASATokenMapper.swift
//  Botsi
//
//  Created by Vladyslav on 07.05.2025.
//

import Foundation

struct BotsiASATokenMapper: DomainMapper {
    typealias Parameters = (profileId: String, token: String)
    
    typealias DTOResponseModel = BotsiASATokenResponseDto
    
    typealias DTORequestModel = BotsiASATokenRequestDto
    
    typealias DomainModel = BotsiProfile
    
    func toDTO(from parameters: Parameters) -> BotsiASATokenRequestDto {
        return BotsiASATokenRequestDto(
            profileId: parameters.profileId,
            token: parameters.token
        )
    }
    
    func toDomain(from dto: BotsiASATokenResponseDto) -> BotsiProfile {
        return dto.data
    }
}
