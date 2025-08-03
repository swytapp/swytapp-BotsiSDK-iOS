//
//  BotsiUpdateProfileRepository.swift
//  Botsi
//
//  Created by Vladyslav on 27.05.2025.
//

import Foundation

protocol BotsiUpdateProfileRepository {
    func updateUserProfile(
        identifier: String,
        profileUpdate: BotsiUserProfileInformation
    ) async throws -> BotsiProfile
}

final class UpdateUserProfileRepository: BotsiUpdateProfileRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: UpdateProfileMapper

    init(httpClient: BotsiHttpClient, mapper: UpdateProfileMapper = UpdateProfileMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func updateUserProfile(
        identifier: String,
        profileUpdate: BotsiUserProfileInformation
    ) async throws -> BotsiProfile {
        do {
            var request = UpdateProfileRequest(uuid: identifier)
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            
            let body = try mapper.toDTO(from: profileUpdate).toData()
            request.body = body
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            do {
                let responseDto: UpdateProfileDtoResponse = try wrapper.decode()
                return mapper.toDomain(from: responseDto)
            } catch {
                let errorDto: UpdateProfileErrorDtoResponse = try wrapper.decode()
                if errorDto.status == 403 {
                    throw BotsiError.sdkActivationKeyNotValid
                } else {
                    throw BotsiError.customError(errorDto.message, "Status code: \(errorDto.status)")
                }
            }
        } catch let error as BotsiError {
            throw error
        } catch {
            throw BotsiError.networkError(error.localizedDescription)
        }
    }
}
