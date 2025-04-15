//
//  BotsiRestorePurchaseMapper.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//

import Foundation

struct BotsiRestorePurchaseMapper: DomainMapper {
    typealias Parameters = (profileId: String, receipt: Data)
    
    typealias DTOResponseModel = BotsiRestorePurchaseResponseDto
    
    typealias DTORequestModel = BotsiValidateReceiptRequestDto
    
    typealias DomainModel = BotsiProfile
    
    func toDTO(from parameters: Parameters) -> BotsiValidateReceiptRequestDto {
        return BotsiValidateReceiptRequestDto(
            receipt: parameters.receipt,
            profileId: parameters.profileId
        )
    }
    
    func toDomain(from dto: BotsiRestorePurchaseResponseDto) -> BotsiProfile {
        return dto.data
    }
}
