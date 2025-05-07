//
//  BotsiOfferEligibilityRepository.swift
//  Botsi
//
//  Created by Vladyslav on 26.04.2025.
//

import Foundation

protocol BotsiOfferEligibilityRepository {
    func getElligibleOffers(profileId: String, productIds: [String]) async throws -> [BotsiOfferEligibilityData]
}

final class OfferEligibilityRepository: BotsiOfferEligibilityRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiOfferEligibilityMapper

    init(httpClient: BotsiHttpClient, mapper: BotsiOfferEligibilityMapper = BotsiOfferEligibilityMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func getElligibleOffers(profileId: String, productIds: [String]) async throws -> [BotsiOfferEligibilityData] {
        do {
            var request = OfferEligibilityRequest(queryParameters: [
                "profileId": profileId,
                "productIds": productIds.joined(separator: ",")
            ])
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            
            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: BotsiOfferEligibilityDto = try wrapper.decode()
            let eligibleOffers = mapper.toDomain(from: responseDto)
            return eligibleOffers
            
        } catch let error as BotsiError {
            throw BotsiError.customError("Sign Promotional Offer Error", "API request failed. Botsi error: \(error.localizedDescription)")
        } catch {
            throw BotsiError.customError("Sign promo offfer error", "api \(error.localizedDescription)")
        }
    }
}
