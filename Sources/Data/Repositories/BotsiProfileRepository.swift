//
//  BotsiProfileRepository.swift
//  Botsi
//
//  Created by Vladyslav on 23.02.2025.
//
import Foundation

protocol BotsiProfileRepository {
    func createUserProfile(identifier: String) async throws -> BotsiProfile
}

final class UserProfileRepository: BotsiProfileRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: CreateProfileMapper

    init(httpClient: BotsiHttpClient, mapper: CreateProfileMapper = CreateProfileMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func createUserProfile(identifier: String) async throws -> BotsiProfile {
        do {
            var request = CreateProfileRequest(uuid: identifier)
            request.headers = [
                "Authorization": "pk_O50YzT5HvlY1fSOP.6en44PYDcnIK2HOzIJi9FUYIE",
                "Content-type": "application/json"
            ]
            
            let environment = try await BotsiEnvironment()
            let body = try mapper.toDTO(from: environment).toData()
            request.body = body
            
            print("url: \(request.relativePath) ")
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: CreateProfileDtoResponse = try wrapper.decode()
            
            // TODO: Store response into Profile Storage
            print("Response json: \(responseDto)")
            return mapper.toDomain(from: responseDto)

        } catch {
            print("Request failed with error: \(error)")
            throw BotsiError.userCreationFailed
        }
    }
}
