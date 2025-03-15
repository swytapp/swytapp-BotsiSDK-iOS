//
//  BotsiRestorePurchaseMapper.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//

import Foundation

struct BotsiRestorePurchaseMapper: DomainMapper {
    typealias Parameters = (transaction: BotsiPaymentTransaction, profileId: String, environment: BotsiEnvironment)
    
    typealias DTOResponseModel = BotsiRestorePurchaseResponseDto
    
    typealias DTORequestModel = BotsiRestorePurchaseRequestDto
    
    typealias DomainModel = BotsiProfile
    
    func toDTO(from parameters: Parameters) -> BotsiRestorePurchaseRequestDto {
        let transaction = parameters.transaction
        let profileId = parameters.profileId
        let config = parameters.environment
        
        return BotsiRestorePurchaseRequestDto(
            originalTransactionId: transaction.originalTransactionId,
            profileId: profileId,
            storeCountry: transaction.storeCountry ?? "",
            botsiSdkVersion: config.botsiSdkVersion,
            appBuild: config.appBuild,
            appVersion: config.appVersion,
            device: config.device,
            locale: config.locale,
            os: config.os
        )
    }
    
    func toDomain(from dto: BotsiRestorePurchaseResponseDto) -> BotsiProfile {
        return dto.data
    }
}
