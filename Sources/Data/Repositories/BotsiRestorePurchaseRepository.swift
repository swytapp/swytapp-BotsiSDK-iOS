//
//  BotsiRestorePurchaseRepository.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//

import Foundation

protocol BotsiRestorePurchaseRepository {
    func restore(transaction: BotsiPaymentTransaction) async throws -> BotsiProfile
}

final class RestorePurchaseRepository: BotsiRestorePurchaseRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiRestorePurchaseMapper
    private let profileId: String
    private let configuration: BotsiConfiguration

    init(httpClient: BotsiHttpClient,
         profileId: String,
         mapper: BotsiRestorePurchaseMapper = BotsiRestorePurchaseMapper(),
         configuration: BotsiConfiguration
    ) {
        self.httpClient = httpClient
        self.mapper = mapper
        self.profileId = profileId
        self.configuration = configuration
    }

    func restore(transaction: BotsiPaymentTransaction) async throws -> BotsiProfile {
        do {
            var request = RestorePurchaseRequest()
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            
            let environment = try await BotsiEnvironment()
            
            let requestParameters = (transaction, profileId, environment)
            let body = try mapper.toDTO(from: requestParameters).toData()
            request.body = body
            
            print("Restoring transaction: \(transaction.description)")
            
            print("Restoring transaction url: \(request.relativePath)")
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: BotsiRestorePurchaseResponseDto = try wrapper.decode()
            
            print("Restore response json: \(responseDto)")
            return mapper.toDomain(from: responseDto)

        } catch {
            print("Restore request failed with error: \(error)")
            throw BotsiError.restoreFailed
        }
    }
}
