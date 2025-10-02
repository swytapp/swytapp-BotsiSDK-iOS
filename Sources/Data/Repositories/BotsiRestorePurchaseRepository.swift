//
//  BotsiRestorePurchaseRepository.swift
//  Botsi
//
//  Created by Vladyslav on 15.03.2025.
//

import Foundation

protocol BotsiRestorePurchaseRepository {
    func restore(receipt: Data) async throws -> BotsiProfile
}

final class RestorePurchaseRepository: BotsiRestorePurchaseRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiRestorePurchaseMapper
    private let profileId: String

    init(httpClient: BotsiHttpClient,
         profileId: String,
         mapper: BotsiRestorePurchaseMapper = BotsiRestorePurchaseMapper()
    ) {
        self.httpClient = httpClient
        self.mapper = mapper
        self.profileId = profileId
    }
    
    func restore(receipt: Data) async throws -> BotsiProfile {
        do {
            var request = RestorePurchaseRequest()
            request.headers = [
                "Authorization": "sk_ElLDOD5E8Eq4v5y.XlJOTtEIqK9bL15J3C7ofuxag",
                "Content-type": "application/json"
            ]
            debugPrint("Restore Purchase Request profiledId: \(profileId)")
            debugPrint("Restore Purchase Request URL: \(request.url?.absoluteString)")
            
            let requestParameters = (profileId, receipt)
            let body = try mapper.toDTO(from: requestParameters).toData()
            request.body = body
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })

            debugPrint("Restore Purchase Response: \(String(data: response.body, encoding: .utf8))")

            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: BotsiRestorePurchaseResponseDto = try wrapper.decode()

            return mapper.toDomain(from: responseDto)
        } catch {
            throw BotsiError.restoreFailed
        }
    }
}
