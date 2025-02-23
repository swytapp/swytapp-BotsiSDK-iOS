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
    
    func toDTO(from model: BotsiEnvironment) -> CreateProfileRequestDto {
        // TODO: get environemnt variables
        
        return CreateProfileRequestDto(
            meta: CreateProfileMetaDto(
                storeCountry: "UA",
                botsiSdkVersion: "1.0.0", // Hardcoded for now
                advertisingId: UUID().uuidString,
                androidId: UUID().uuidString,
                appBuild: "1",
                androidAppSetId: UUID().uuidString,
                appVersion: "1",
                device: "iPhone12",
                deviceId: UUID().uuidString,
                locale: "en-US",
                os: "apple",
                platform: "ios",
                timezone: "Europe/Kiev"
            )
        )
    }
    
    func toDomain(from dto: CreateProfileDtoResponse) -> BotsiProfile {
        return dto.data
    }
}
