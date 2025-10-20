//
//  BotsiGetPaywallBuilderRepository.swift
//  Botsi
//
//  Created by Vladyslav Danyliak on 14.10.2025.
//

import Foundation

protocol BotsiGetPaywallBuilderRepository {
    func getPaywallBuilder(paywallId: Int) async throws -> Data
}

final class GetPaywallBuilderRepository: BotsiGetPaywallBuilderRepository {
    private let httpClient: BotsiHttpClient
    private let paywallId: Int
    
    init(httpClient: BotsiHttpClient,
         paywallId: Int
    ) {
        self.httpClient = httpClient
        self.paywallId = paywallId
    }
    
    func getPaywallBuilder(paywallId: Int) async throws -> Data {
        do {
            var request = GetPaywallBuilderRequest(paywallId: paywallId)
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            
            return response.body
        } catch {
            BotsiLog.error("Failed to fetch builder with paywallId \(paywallId): \(error.localizedDescription)")
            throw BotsiError.paywallFetchingFailed
        }
    }
}
