//
//  BotsiGetPaywallRepository.swift
//  Botsi
//
//  Created by Vladyslav on 22.03.2025.
//

import Foundation

protocol BotsiGetPaywallRepository {
    func getPaywall(id: String) async throws -> BotsiPaywall
}

final class GetPaywallRepository: BotsiGetPaywallRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiGetPaywallMapper
    private let profileId: String
    
    init(httpClient: BotsiHttpClient,
         profileId: String,
         mapper: BotsiGetPaywallMapper = BotsiGetPaywallMapper()
    ) {
        self.httpClient = httpClient
        self.mapper = mapper
        self.profileId = profileId
    }
    
    func getPaywall(id: String) async throws -> BotsiPaywall {
        do {
            var request = GetPaywallRequest(placementId: id, queryParameters: [
                "profileId": profileId,
                "store": "app_store"
            ])
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            
            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: BotsiGetPaywallResponseDto = try wrapper.decode()
            
            return mapper.toDomain(from: responseDto)
        } catch {
            print("Get paywall request failed with error: \(error)")
            throw BotsiError.getPaywallFailed
        }
    }
}
