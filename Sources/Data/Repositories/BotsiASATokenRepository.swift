//
//  BotsiASATokenRepository.swift
//  Botsi
//
//  Created by Vladyslav on 07.05.2025.
//

import Foundation

protocol BotsiASATokenRepository {
    func sendASAToken(profileId: String, token: String) async throws -> BotsiProfile
}

final class ASATokenRepository: BotsiASATokenRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiASATokenMapper

    init(httpClient: BotsiHttpClient, mapper: BotsiASATokenMapper = BotsiASATokenMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func sendASAToken(profileId: String, token: String) async throws -> BotsiProfile {
        do {
            var request = SendASATokenRequest()
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            let parameters = (profileId, token)
            let body = try mapper.toDTO(from: parameters).toData()
            request.body = body
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let result: BotsiASATokenResponseDto = try wrapper.decode()
            return result.data
        } catch {
            throw BotsiError.asaTokenError
        }
    }
}
