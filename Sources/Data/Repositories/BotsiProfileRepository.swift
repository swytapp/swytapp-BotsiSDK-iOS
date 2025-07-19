//
//  BotsiProfileRepository.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//
import Foundation

protocol BotsiProfileRepository {
    func createUserProfile(identifier: String, customerId: String?, birthday: Date?) async throws -> BotsiProfile
}

final class UserProfileRepository: BotsiProfileRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: CreateProfileMapper

    init(httpClient: BotsiHttpClient, mapper: CreateProfileMapper = CreateProfileMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func createUserProfile(identifier: String, customerId: String? = nil, birthday: Date? = nil) async throws -> BotsiProfile {
        do {
            var request = CreateProfileRequest(uuid: identifier)
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            
            let environment = try await BotsiEnvironment()
            var birthdayStringValue: String?
            if let birthday {
                birthdayStringValue = birthday.toISO8601DateString()
            }
            let params = (environment, customerId, birthdayStringValue)
            let body = try mapper.toDTO(from: params).toData()
            request.body = body
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: CreateProfileDtoResponse = try wrapper.decode()
            return mapper.toDomain(from: responseDto)

        } catch {
            BotsiLog.error("Failed to create user profile: \(error.localizedDescription)")
            throw BotsiError.userCreationFailed
        }
    }
}
