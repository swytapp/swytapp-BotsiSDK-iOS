//
//  BotsiProfileMapper.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation

struct CreateProfileMapper: DomainMapper {
    typealias Parameters = BotsiEnvironment
    
    typealias DTOResponseModel = CreateProfileDtoResponse
    
    typealias DTORequestModel = CreateProfileRequestDto
    
    typealias DomainModel = BotsiProfile
    
    func toDTO(from env: BotsiEnvironment) -> CreateProfileRequestDto {
        return CreateProfileRequestDto(
            meta: CreateProfileMetaDto(
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
