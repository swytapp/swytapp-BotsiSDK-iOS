//
//  BotsiProfileMapper.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation

struct CreateProfileMapper: DomainMapper {
    typealias Parameters = (environment: BotsiEnvironment, customerUserId: String?)
    
    typealias DTOResponseModel = CreateProfileDtoResponse
    
    typealias DTORequestModel = CreateProfileRequestDto
    
    typealias DomainModel = BotsiProfile
    
    func toDTO(from params: Parameters) -> CreateProfileRequestDto {
        let env = params.environment
        return CreateProfileRequestDto(
            meta: CreateProfileMetaDto(
                customerUserId: params.customerUserId,
                storeCountry: env.storeCountry,
                botsiSdkVersion: env.botsiSdkVersion,
                advertisingId: env.advertisingId,
                androidId: env.androidId,
                appBuild: env.appBuild,
                androidAppSetId: env.androidAppSetId,
                appVersion: env.appVersion,
                device: env.device,
                deviceId: env.deviceId,
                locale: env.locale,
                os: env.os,
                platform: env.platform,
                timezone: env.timezone
            )
        )
    }
    
    func toDomain(from dto: CreateProfileDtoResponse) -> BotsiProfile {
        return dto.data
    }
}

struct UpdateProfileMapper: DomainMapper {
    typealias Parameters = String
    
    typealias DTOResponseModel = UpdateProfileDtoResponse
    
    typealias DTORequestModel = BotsiUpdateProfileRequestDto
    
    typealias DomainModel = BotsiProfile
    
    func toDTO(from params: Parameters) -> BotsiUpdateProfileRequestDto {
        return BotsiUpdateProfileRequestDto(ip: params)
        
    }
    
    func toDomain(from dto: UpdateProfileDtoResponse) -> BotsiProfile {
        return dto.data
    }
}
