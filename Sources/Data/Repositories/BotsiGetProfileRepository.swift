//
//  BotsiGetProfileRepository.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//

import Foundation

protocol BotsiGetProfileRepository {
    func getUserProfile(identifier: String) async throws -> BotsiProfile
}

final class GetUserProfileRepository: BotsiGetProfileRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: CreateProfileMapper

    init(httpClient: BotsiHttpClient, mapper: CreateProfileMapper = CreateProfileMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func getUserProfile(identifier: String) async throws -> BotsiProfile {
        do {
            var request = GetProfileRequest(uuid: identifier)
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: CreateProfileDtoResponse = try wrapper.decode()
            return mapper.toDomain(from: responseDto)

        } catch {
            BotsiLog.error("Failed to fetch user profile: \(error.localizedDescription)")
            throw BotsiError.userGetProfileFailed
        }
    }
}
