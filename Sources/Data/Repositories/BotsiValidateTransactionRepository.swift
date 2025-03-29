//
//  BotsiValidateTransactionRepository.swift
//  Botsi
//
//  Created by Vladyslav on 10.03.2025.
//

import Foundation

protocol BotsiValidateTransactionRepository {
    func validateTransaction(transaction: BotsiPaymentTransaction) async throws -> BotsiProfile
}

final class ValidateTransactionRepository: BotsiValidateTransactionRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiValidateTransactionMapper
    private let profileId: String

    init(httpClient: BotsiHttpClient, profileId: String, mapper: BotsiValidateTransactionMapper = BotsiValidateTransactionMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
        self.profileId = profileId
    }

    func validateTransaction(transaction: BotsiPaymentTransaction) async throws -> BotsiProfile {
        do {
            var request = ValidateTransactionRequest()
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            let requestParameters = (transaction, profileId)
            let body = try mapper.toDTO(from: requestParameters).toData()
            request.body = body
            
            print("Validating transaction: \(transaction.description)")
            
            print("Validating transaction url: \(request.relativePath)")
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: BotsiValidateTransactionResponseDto = try wrapper.decode()
            
            // TODO: Store response into Profile Storage
            print("Response json: \(responseDto)")
            return mapper.toDomain(from: responseDto)

        } catch {
            print("Request failed with error: \(error)")
            throw BotsiError.transactionFailed
        }
    }
}
