//
//  BotsiSignOfferRepository.swift
//  Botsi
//
//  Created by Vladyslav on 19.04.2025.
//

import Foundation

protocol BotsiSignOfferRepository {
    func getSignedPromotionalOffer(productId: String, offerId: String) async throws -> BotsiSignSubscriptionOfferResponseData
}

final class SignPromotionalOfferRepository: BotsiSignOfferRepository {
    private let httpClient: BotsiHttpClient
    private let mapper: BotsiSignOfferMapper

    init(httpClient: BotsiHttpClient, mapper: BotsiSignOfferMapper = BotsiSignOfferMapper()) {
        self.httpClient = httpClient
        self.mapper = mapper
    }

    func getSignedPromotionalOffer(productId: String, offerId: String) async throws -> BotsiSignSubscriptionOfferResponseData {
        do {
            var request = SignPromotionalOfferRequest(queryParameters: [
                "offerId": offerId,
                "productId": productId
            ])
            request.headers = [
                "Authorization": httpClient.sdkApiKey,
                "Content-type": "application/json"
            ]
            /*let parameters = (profileId, paywallId, abTestId, eventType)
            let body = try mapper.toDTO(from: parameters).toData()
            request.body = body*/
            
            let response: BotsiHTTPResponse<Data> = try await httpClient.session.perform(request, withDecoder: { dataResponse in
                return BotsiHTTPResponse(body: dataResponse.data)
            })
            
            let wrapper = BotsiHTTPResponseWrapper(data: response.body)
            let responseDto: BotsiSignSubscriptionOfferResponseDto = try wrapper.decode()
            let signOfferMeta = mapper.toDomain(from: responseDto)
            
            return signOfferMeta
            
        } catch let error as BotsiError {
            throw BotsiError.customError("Sign Promotional Offer Error", "API request failed. Botsi error: \(error.localizedDescription)")
        } catch {
            throw BotsiError.customError("Sign promo offfer error", "api \(error.localizedDescription)")
        }
    }
}
